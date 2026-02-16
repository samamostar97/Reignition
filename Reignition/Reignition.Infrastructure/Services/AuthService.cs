using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Exceptions;
using Reignition.Application.IRepositories;
using Reignition.Application.IServices;
using Reignition.Core.Entities;
using Reignition.Core.Enums;

namespace Reignition.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly IRepository<User> _userRepository;
    private readonly IConfiguration _configuration;

    public AuthService(IRepository<User> userRepository, IConfiguration configuration)
    {
        _userRepository = userRepository;
        _configuration = configuration;
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await _userRepository.AsQueryable()
            .FirstOrDefaultAsync(x => x.Username.ToLower() == request.Username.ToLower());

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            throw new InvalidOperationException("Pogrešno korisničko ime ili lozinka.");

        if (!user.IsActive)
            throw new ForbiddenException("Vaš nalog je deaktiviran. Kontaktirajte administratora.");

        return new AuthResponse
        {
            Token = GenerateJwtToken(user),
            User = user.Adapt<UserResponse>()
        };
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        var usernameExists = await _userRepository.AsQueryable()
            .AnyAsync(x => x.Username.ToLower() == request.Username.ToLower());

        if (usernameExists)
            throw new ConflictException("Korisničko ime je već zauzeto.");

        var emailExists = await _userRepository.AsQueryable()
            .AnyAsync(x => x.Email.ToLower() == request.Email.ToLower());

        if (emailExists)
            throw new ConflictException("Korisnik sa ovim emailom već postoji.");

        var user = request.Adapt<User>();
        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        user.Role = Role.Member;
        user.IsActive = true;

        await _userRepository.AddAsync(user);

        return new AuthResponse
        {
            Token = GenerateJwtToken(user),
            User = user.Adapt<UserResponse>()
        };
    }

    public async Task<UserResponse> GetProfileAsync(int userId)
    {
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen.");

        return user.Adapt<UserResponse>();
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordRequest request)
    {
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen.");

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
            throw new InvalidOperationException("Trenutna lozinka nije ispravna.");

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _userRepository.UpdateAsync(user);
    }

    private string GenerateJwtToken(User user)
    {
        var secret = _configuration["Jwt:Secret"]
            ?? throw new InvalidOperationException("JWT Secret nije konfigurisan.");
        var issuer = _configuration["Jwt:Issuer"];
        var audience = _configuration["Jwt:Audience"];
        var expirationHours = int.Parse(_configuration["Jwt:ExpirationInHours"] ?? "24");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(expirationHours),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
