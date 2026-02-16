using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Exceptions;
using Reignition.Application.Filters;
using Reignition.Application.Helpers;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Core.Entities;
using Reignition.Core.Enums;

namespace Reignition.Infrastructure.Services;

public class UserService : BaseService<User, UserResponse, object, UpdateUserRequest, UserQueryFilter>, IUserService
{
    public UserService(IRepository<User> repository) : base(repository) { }

    protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserQueryFilter filter)
    {
        query = query.Where(x => x.Role != Role.Admin);

        query = query.WhereIf(!string.IsNullOrEmpty(filter.Search),
            x => x.Username.ToLower().Contains(filter.Search!.ToLower())
              || x.FirstName.ToLower().Contains(filter.Search!.ToLower())
              || x.LastName.ToLower().Contains(filter.Search!.ToLower())
              || x.Email.ToLower().Contains(filter.Search!.ToLower()));

        query = query.WhereIf(filter.Role.HasValue, x => x.Role == filter.Role!.Value);
        query = query.WhereIf(filter.IsActive.HasValue, x => x.IsActive == filter.IsActive!.Value);

        return filter.OrderBy?.ToLower() switch
        {
            "name" => query.OrderBy(x => x.FirstName).ThenBy(x => x.LastName),
            "email" => query.OrderBy(x => x.Email),
            _ => query.OrderByDescending(x => x.CreatedAt)
        };
    }

    protected override async Task ValidateUpdateAsync(User entity, UpdateUserRequest dto)
    {
        if (!string.IsNullOrEmpty(dto.Username))
        {
            var usernameExists = await _repository.AsQueryable()
                .AnyAsync(x => x.Username.ToLower() == dto.Username.ToLower() && x.Id != entity.Id);
            if (usernameExists)
                throw new ConflictException("Korisničko ime je već zauzeto.");
        }

        if (!string.IsNullOrEmpty(dto.Email))
        {
            var emailExists = await _repository.AsQueryable()
                .AnyAsync(x => x.Email.ToLower() == dto.Email.ToLower() && x.Id != entity.Id);
            if (emailExists)
                throw new ConflictException("Korisnik sa ovim emailom već postoji.");
        }
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Where(x => x.Role != Role.Admin)
            .OrderBy(x => x.FirstName)
            .Select(x => new LookupResponse
            {
                Id = x.Id,
                Name = x.FirstName + " " + x.LastName
            })
            .ToListAsync();
    }
}
