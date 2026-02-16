using Reignition.Application.Common;

namespace Reignition.Application.IServices;

public interface IBaseService<TResponse, TCreate, TUpdate, TFilter>
    where TFilter : PaginationRequest
{
    Task<PagedResult<TResponse>> GetAllAsync(TFilter filter);
    Task<TResponse> GetByIdAsync(int id);
    Task<TResponse> CreateAsync(TCreate dto);
    Task<TResponse> UpdateAsync(int id, TUpdate dto);
    Task DeleteAsync(int id);
    Task<List<LookupResponse>> GetLookupAsync();
}
