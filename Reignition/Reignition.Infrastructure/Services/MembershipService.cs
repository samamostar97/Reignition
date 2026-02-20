using Mapster;
using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Filters;
using Reignition.Application.Helpers;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Core.Entities;
using Reignition.Core.Enums;

namespace Reignition.Infrastructure.Services;

public class MembershipService
    : BaseService<Membership, MembershipResponse, CreateMembershipRequest, UpdateMembershipRequest, MembershipQueryFilter>,
      IMembershipService
{
    private readonly IRepository<User> _userRepository;
    private readonly IRepository<MembershipType> _membershipTypeRepository;

    public MembershipService(
        IRepository<Membership> repository,
        IRepository<User> userRepository,
        IRepository<MembershipType> membershipTypeRepository)
        : base(repository)
    {
        _userRepository = userRepository;
        _membershipTypeRepository = membershipTypeRepository;
    }

    protected override IQueryable<Membership> ApplyFilter(IQueryable<Membership> query, MembershipQueryFilter filter)
    {
        query = query
            .Include(x => x.User)
            .Include(x => x.MembershipType);

        query = query
            .WhereIf(filter.UserId.HasValue,
                x => x.UserId == filter.UserId!.Value)
            .WhereIf(filter.MembershipTypeId.HasValue,
                x => x.MembershipTypeId == filter.MembershipTypeId!.Value)
            .WhereIf(filter.Status.HasValue,
                x => x.Status == filter.Status!.Value)
            .WhereIf(!string.IsNullOrEmpty(filter.Search),
                x => (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(filter.Search!.ToLower()));

        return filter.OrderBy?.ToLower() switch
        {
            "startdate" => query.OrderBy(x => x.StartDate),
            "enddate" => query.OrderBy(x => x.EndDate),
            _ => query.OrderByDescending(x => x.CreatedAt)
        };
    }

    public override async Task<MembershipResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.AsQueryable()
            .Include(x => x.User)
            .Include(x => x.MembershipType)
            .FirstOrDefaultAsync(x => x.Id == id)
            ?? throw new KeyNotFoundException("Članarina nije pronađena.");

        return entity.Adapt<MembershipResponse>();
    }

    protected override async Task ValidateCreateAsync(Membership entity, CreateMembershipRequest dto)
    {
        var userExists = await _userRepository.AsQueryable().AnyAsync(u => u.Id == dto.UserId);
        if (!userExists) throw new KeyNotFoundException("Korisnik ne postoji.");

        var typeExists = await _membershipTypeRepository.AsQueryable()
            .AnyAsync(t => t.Id == dto.MembershipTypeId && t.IsActive);
        if (!typeExists) throw new KeyNotFoundException("Tip članarine ne postoji ili nije aktivan.");

        var hasActive = await _repository.AsQueryable()
            .AnyAsync(m => m.UserId == dto.UserId && m.Status == MembershipStatus.Active);
        if (hasActive)
            throw new InvalidOperationException("Korisnik već ima aktivnu članarinu.");
    }

    protected override async Task PrepareCreateAsync(Membership entity, CreateMembershipRequest dto)
    {
        var membershipType = await _membershipTypeRepository.GetByIdAsync(dto.MembershipTypeId);
        var startDate = dto.StartDate?.ToUniversalTime() ?? DateTimeUtils.UtcNow;

        entity.StartDate = startDate;
        entity.EndDate = startDate.AddDays(membershipType!.DurationInDays);
        entity.Status = MembershipStatus.Active;
    }

    protected override async Task ValidateUpdateAsync(Membership entity, UpdateMembershipRequest dto)
    {
        if (dto.MembershipTypeId.HasValue)
        {
            var typeExists = await _membershipTypeRepository.AsQueryable()
                .AnyAsync(t => t.Id == dto.MembershipTypeId.Value && t.IsActive);
            if (!typeExists) throw new KeyNotFoundException("Tip članarine ne postoji ili nije aktivan.");
        }
    }

    protected override async Task PrepareUpdateAsync(Membership entity, UpdateMembershipRequest dto)
    {
        if (dto.MembershipTypeId.HasValue || dto.StartDate.HasValue)
        {
            var membershipType = await _membershipTypeRepository.GetByIdAsync(
                dto.MembershipTypeId ?? entity.MembershipTypeId);

            if (dto.StartDate.HasValue)
                entity.StartDate = dto.StartDate.Value.ToUniversalTime();

            entity.EndDate = entity.StartDate.AddDays(membershipType!.DurationInDays);
        }
    }

    protected override async Task AfterCreateAsync(Membership entity, CreateMembershipRequest dto)
    {
        entity.User = (await _userRepository.GetByIdAsync(entity.UserId))!;
        entity.MembershipType = (await _membershipTypeRepository.GetByIdAsync(entity.MembershipTypeId))!;
    }

    protected override async Task AfterUpdateAsync(Membership entity, UpdateMembershipRequest dto)
    {
        entity.User = (await _userRepository.GetByIdAsync(entity.UserId))!;
        entity.MembershipType = (await _membershipTypeRepository.GetByIdAsync(entity.MembershipTypeId))!;
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Include(x => x.User)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new LookupResponse
            {
                Id = x.Id,
                Name = x.User.FirstName + " " + x.User.LastName
            })
            .ToListAsync();
    }

    public async Task<List<MembershipResponse>> GetMyMembershipsAsync(int userId)
    {
        var memberships = await _repository.AsQueryable()
            .Include(x => x.User)
            .Include(x => x.MembershipType)
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return memberships.Adapt<List<MembershipResponse>>();
    }
}
