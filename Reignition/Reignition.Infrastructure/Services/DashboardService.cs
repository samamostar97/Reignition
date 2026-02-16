using Microsoft.EntityFrameworkCore;
using Reignition.Application.Common;
using Reignition.Application.DTOs.Response;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Core.Entities;
using Reignition.Core.Enums;

namespace Reignition.Infrastructure.Services;

public class DashboardService : IDashboardService
{
    private readonly IRepository<User> _userRepository;
    private readonly IRepository<Membership> _membershipRepository;

    public DashboardService(IRepository<User> userRepository, IRepository<Membership> membershipRepository)
    {
        _userRepository = userRepository;
        _membershipRepository = membershipRepository;
    }

    public async Task<DashboardStatsResponse> GetStatsAsync()
    {
        var now = DateTimeUtils.UtcNow;
        var sevenDaysFromNow = now.AddDays(7);
        var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);

        var totalMembers = await _userRepository.AsQueryable()
            .CountAsync(u => u.Role == Role.Member);

        var activeMemberships = await _membershipRepository.AsQueryable()
            .CountAsync(m => m.Status == MembershipStatus.Active);

        var expiringSoon = await _membershipRepository.AsQueryable()
            .CountAsync(m => m.Status == MembershipStatus.Active
                          && m.EndDate >= now
                          && m.EndDate <= sevenDaysFromNow);

        var monthlyRevenue = await _membershipRepository.AsQueryable()
            .Include(m => m.MembershipType)
            .Where(m => m.CreatedAt >= monthStart)
            .Select(m => (decimal?)m.MembershipType.Price)
            .SumAsync() ?? 0m;

        return new DashboardStatsResponse
        {
            TotalMembers = totalMembers,
            ActiveMemberships = activeMemberships,
            ExpiringSoon = expiringSoon,
            MonthlyRevenue = monthlyRevenue
        };
    }
}
