using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Application.IRepositories;
using Reignition.Core.Entities;
using Reignition.Infrastructure.Data;

namespace Reignition.Infrastructure.Repositories;

public class BaseRepository<T> : IRepository<T> where T : BaseEntity
{
    protected readonly ReignitionDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public BaseRepository(ReignitionDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(int id)
        => await _dbSet.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);

    public async Task<List<T>> GetAllAsync()
        => await _dbSet.Where(x => !x.IsDeleted).ToListAsync();

    public async Task AddAsync(T entity)
    {
        entity.CreatedAt = DateTimeUtils.UtcNow;
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(T entity)
    {
        entity.UpdatedAt = DateTimeUtils.UtcNow;
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(T entity)
    {
        entity.IsDeleted = true;
        entity.UpdatedAt = DateTimeUtils.UtcNow;
        await _context.SaveChangesAsync();
    }

    public IQueryable<T> AsQueryable()
        => _dbSet.Where(x => !x.IsDeleted).AsQueryable();
}
