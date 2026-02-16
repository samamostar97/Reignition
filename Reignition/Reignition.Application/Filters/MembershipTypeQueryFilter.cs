using Reignition.Application.Common;

namespace Reignition.Application.Filters;

public class MembershipTypeQueryFilter : PaginationRequest
{
    public bool? IsActive { get; set; }
}
