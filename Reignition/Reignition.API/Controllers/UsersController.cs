using Microsoft.AspNetCore.Authorization;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Filters;
using Reignition.Application.IServices;

namespace Reignition.API.Controllers;

[Authorize(Roles = "Admin")]
public class UsersController : BaseController<UserResponse, object, UpdateUserRequest, UserQueryFilter>
{
    public UsersController(IUserService userService) : base(userService) { }
}
