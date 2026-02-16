using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Response;

public class MembershipResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public int MembershipTypeId { get; set; }
    public string MembershipTypeName { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public MembershipStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
