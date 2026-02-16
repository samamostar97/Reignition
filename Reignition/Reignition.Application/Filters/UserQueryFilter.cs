using Reignition.Application.Common;
using Reignition.Core.Enums;

namespace Reignition.Application.Filters;

public class UserQueryFilter : PaginationRequest
{
    public Role? Role { get; set; }
    public bool? IsActive { get; set; }
}
