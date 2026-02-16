using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;

namespace Reignition.Application.IServices;

public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse> RegisterAsync(RegisterRequest request);
    Task<UserResponse> GetProfileAsync(int userId);
    Task ChangePasswordAsync(int userId, ChangePasswordRequest request);
}
