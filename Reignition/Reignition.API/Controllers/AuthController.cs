using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.IServices;

namespace Reignition.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IMembershipService _membershipService;

    public AuthController(IAuthService authService, IMembershipService membershipService)
    {
        _authService = authService;
        _membershipService = membershipService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
        => Ok(await _authService.LoginAsync(request));

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
        => Ok(await _authService.RegisterAsync(request));

    [HttpGet("profile")]
    [Authorize]
    public async Task<ActionResult<UserResponse>> GetProfile()
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        return Ok(await _authService.GetProfileAsync(userId));
    }

    [HttpPut("change-password")]
    [Authorize]
    public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _authService.ChangePasswordAsync(userId, request);
        return NoContent();
    }

    [HttpGet("my-memberships")]
    [Authorize]
    public async Task<ActionResult<List<MembershipResponse>>> GetMyMemberships()
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        return Ok(await _membershipService.GetMyMembershipsAsync(userId));
    }
}
