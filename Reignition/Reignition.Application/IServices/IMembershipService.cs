using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Filters;

namespace Reignition.Application.IServices;

public interface IMembershipService
    : IBaseService<MembershipResponse, CreateMembershipRequest, UpdateMembershipRequest, MembershipQueryFilter>
{
    Task<List<MembershipResponse>> GetMyMembershipsAsync(int userId);
}
