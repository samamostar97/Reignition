namespace Reignition.Application.DTOs.Response;

public class DashboardStatsResponse
{
    public int TotalMembers { get; set; }
    public int ActiveMemberships { get; set; }
    public int ExpiringSoon { get; set; }
    public decimal MonthlyRevenue { get; set; }
}
