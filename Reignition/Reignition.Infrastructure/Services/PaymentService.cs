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

public class PaymentService
    : BaseService<Payment, PaymentResponse, CreatePaymentRequest, UpdatePaymentRequest, PaymentQueryFilter>,
      IPaymentService
{
    private readonly IRepository<User> _userRepository;
    private readonly IRepository<Membership> _membershipRepository;

    public PaymentService(
        IRepository<Payment> repository,
        IRepository<User> userRepository,
        IRepository<Membership> membershipRepository)
        : base(repository)
    {
        _userRepository = userRepository;
        _membershipRepository = membershipRepository;
    }

    protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentQueryFilter filter)
    {
        query = query
            .Include(x => x.User)
            .Include(x => x.Membership)
                .ThenInclude(m => m!.MembershipType);

        query = query
            .WhereIf(filter.PaymentMethod.HasValue,
                x => x.PaymentMethod == filter.PaymentMethod!.Value)
            .WhereIf(filter.Status.HasValue,
                x => x.Status == filter.Status!.Value)
            .WhereIf(filter.DateFrom.HasValue,
                x => x.TransactionDate >= filter.DateFrom!.Value.ToUniversalTime())
            .WhereIf(filter.DateTo.HasValue,
                x => x.TransactionDate <= filter.DateTo!.Value.ToUniversalTime())
            .WhereIf(!string.IsNullOrEmpty(filter.Search),
                x => (x.User.FirstName + " " + x.User.LastName).ToLower()
                    .Contains(filter.Search!.ToLower()));

        return filter.OrderBy?.ToLower() switch
        {
            "amount" => query.OrderBy(x => x.Amount),
            "date" => query.OrderByDescending(x => x.TransactionDate),
            _ => query.OrderByDescending(x => x.CreatedAt)
        };
    }

    public override async Task<PaymentResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.AsQueryable()
            .Include(x => x.User)
            .Include(x => x.Membership)
                .ThenInclude(m => m!.MembershipType)
            .FirstOrDefaultAsync(x => x.Id == id)
            ?? throw new KeyNotFoundException("Uplata nije pronađena.");

        return entity.Adapt<PaymentResponse>();
    }

    protected override async Task ValidateCreateAsync(Payment entity, CreatePaymentRequest dto)
    {
        var userExists = await _userRepository.AsQueryable().AnyAsync(u => u.Id == dto.UserId);
        if (!userExists) throw new KeyNotFoundException("Korisnik ne postoji.");

        if (dto.MembershipId.HasValue)
        {
            var membershipExists = await _membershipRepository.AsQueryable()
                .AnyAsync(m => m.Id == dto.MembershipId.Value);
            if (!membershipExists) throw new KeyNotFoundException("Članarina ne postoji.");
        }
    }

    protected override Task PrepareCreateAsync(Payment entity, CreatePaymentRequest dto)
    {
        entity.TransactionDate = dto.TransactionDate?.ToUniversalTime() ?? DateTimeUtils.UtcNow;
        entity.Status = PaymentStatus.Completed;
        return Task.CompletedTask;
    }

    protected override async Task ValidateUpdateAsync(Payment entity, UpdatePaymentRequest dto)
    {
        if (dto.MembershipId.HasValue)
        {
            var membershipExists = await _membershipRepository.AsQueryable()
                .AnyAsync(m => m.Id == dto.MembershipId.Value);
            if (!membershipExists) throw new KeyNotFoundException("Članarina ne postoji.");
        }
    }

    protected override async Task AfterCreateAsync(Payment entity, CreatePaymentRequest dto)
    {
        entity.User = (await _userRepository.GetByIdAsync(entity.UserId))!;
        if (entity.MembershipId.HasValue)
        {
            entity.Membership = await _membershipRepository.AsQueryable()
                .Include(m => m.MembershipType)
                .FirstOrDefaultAsync(m => m.Id == entity.MembershipId.Value);
        }
    }

    protected override async Task AfterUpdateAsync(Payment entity, UpdatePaymentRequest dto)
    {
        entity.User = (await _userRepository.GetByIdAsync(entity.UserId))!;
        if (entity.MembershipId.HasValue)
        {
            entity.Membership = await _membershipRepository.AsQueryable()
                .Include(m => m.MembershipType)
                .FirstOrDefaultAsync(m => m.Id == entity.MembershipId.Value);
        }
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Include(x => x.User)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new LookupResponse
            {
                Id = x.Id,
                Name = x.User.FirstName + " " + x.User.LastName + " - " + x.Amount + " KM"
            })
            .ToListAsync();
    }
}
