using Mapster;
using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Services;

public abstract class BaseService<TEntity, TResponse, TCreate, TUpdate, TFilter>
    : IBaseService<TResponse, TCreate, TUpdate, TFilter>
    where TEntity : BaseEntity
    where TFilter : PaginationRequest
{
    protected readonly IRepository<TEntity> _repository;

    protected BaseService(IRepository<TEntity> repository)
    {
        _repository = repository;
    }

    public virtual async Task<PagedResult<TResponse>> GetAllAsync(TFilter filter)
    {
        var query = _repository.AsQueryable();
        query = ApplyFilter(query, filter);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<TResponse>
        {
            Items = items.Adapt<List<TResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize
        };
    }

    public virtual async Task<TResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        return entity.Adapt<TResponse>();
    }

    public virtual async Task<TResponse> CreateAsync(TCreate dto)
    {
        var entity = dto.Adapt<TEntity>();
        await ValidateCreateAsync(entity, dto);
        await PrepareCreateAsync(entity, dto);
        await _repository.AddAsync(entity);
        await AfterCreateAsync(entity, dto);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdate dto)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        await ValidateUpdateAsync(entity, dto);
        dto.Adapt(entity);
        await PrepareUpdateAsync(entity, dto);
        await _repository.UpdateAsync(entity);
        await AfterUpdateAsync(entity, dto);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task DeleteAsync(int id)
    {
        var entity = await _repository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Stavka nije pronađena.");
        await ValidateDeleteAsync(entity);
        await _repository.DeleteAsync(entity);
        await AfterDeleteAsync(entity);
    }

    public virtual async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Select(x => new LookupResponse { Id = x.Id })
            .ToListAsync();
    }

    protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TFilter filter)
        => query.OrderByDescending(x => x.CreatedAt);

    protected virtual Task ValidateCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task ValidateUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task ValidateDeleteAsync(TEntity entity) => Task.CompletedTask;
    protected virtual Task PrepareCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task PrepareUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task AfterCreateAsync(TEntity entity, TCreate dto) => Task.CompletedTask;
    protected virtual Task AfterUpdateAsync(TEntity entity, TUpdate dto) => Task.CompletedTask;
    protected virtual Task AfterDeleteAsync(TEntity entity) => Task.CompletedTask;
}
