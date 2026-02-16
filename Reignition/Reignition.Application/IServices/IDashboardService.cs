using Reignition.Application.DTOs.Response;

namespace Reignition.Application.IServices;

public interface IDashboardService
{
    Task<DashboardStatsResponse> GetStatsAsync();
}
