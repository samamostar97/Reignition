using Microsoft.EntityFrameworkCore;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Exceptions;
using Reignition.Application.Filters;
using Reignition.Application.Helpers;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Application.Common;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Services;

public class MembershipTypeService
    : BaseService<MembershipType, MembershipTypeResponse, CreateMembershipTypeRequest, UpdateMembershipTypeRequest, MembershipTypeQueryFilter>,
      IMembershipTypeService
{
    public MembershipTypeService(IRepository<MembershipType> repository) : base(repository) { }

    protected override IQueryable<MembershipType> ApplyFilter(IQueryable<MembershipType> query, MembershipTypeQueryFilter filter)
    {
        query = query
            .WhereIf(!string.IsNullOrEmpty(filter.Search),
                x => x.Name.ToLower().Contains(filter.Search!.ToLower()))
            .WhereIf(filter.IsActive.HasValue,
                x => x.IsActive == filter.IsActive!.Value);

        return filter.OrderBy?.ToLower() switch
        {
            "name" => query.OrderBy(x => x.Name),
            "price" => query.OrderBy(x => x.Price),
            _ => query.OrderByDescending(x => x.CreatedAt)
        };
    }

    protected override async Task ValidateCreateAsync(MembershipType entity, CreateMembershipTypeRequest dto)
    {
        var exists = await _repository.AsQueryable()
            .AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
        if (exists) throw new ConflictException("Tip članarine sa ovim nazivom već postoji.");
    }

    protected override async Task ValidateUpdateAsync(MembershipType entity, UpdateMembershipTypeRequest dto)
    {
        if (!string.IsNullOrEmpty(dto.Name))
        {
            var exists = await _repository.AsQueryable()
                .AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && x.Id != entity.Id);
            if (exists) throw new ConflictException("Tip članarine sa ovim nazivom već postoji.");
        }
    }

    protected override async Task ValidateDeleteAsync(MembershipType entity)
    {
        var hasActiveMemberships = await _repository.AsQueryable()
            .Where(x => x.Id == entity.Id)
            .SelectMany(x => x.Memberships)
            .AnyAsync(m => !m.IsDeleted && m.Status == Core.Enums.MembershipStatus.Active);
        if (hasActiveMemberships)
            throw new EntityHasDependentsException("tip članarine", "aktivne članarine");
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Where(x => x.IsActive)
            .OrderBy(x => x.Name)
            .Select(x => new LookupResponse { Id = x.Id, Name = x.Name })
            .ToListAsync();
    }
}
