using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reignition.Application.Common;
using Reignition.Application.IServices;

namespace Reignition.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public abstract class BaseController<TResponse, TCreate, TUpdate, TFilter> : ControllerBase
    where TFilter : PaginationRequest
{
    protected readonly IBaseService<TResponse, TCreate, TUpdate, TFilter> _service;

    protected BaseController(IBaseService<TResponse, TCreate, TUpdate, TFilter> service)
    {
        _service = service;
    }

    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetAll([FromQuery] TFilter filter)
        => Ok(await _service.GetAllAsync(filter));

    [HttpGet("{id}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id)
        => Ok(await _service.GetByIdAsync(id));

    [HttpPost]
    public virtual async Task<ActionResult<TResponse>> Create([FromBody] TCreate dto)
        => Ok(await _service.CreateAsync(dto));

    [HttpPut("{id}")]
    public virtual async Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdate dto)
        => Ok(await _service.UpdateAsync(id, dto));

    [HttpDelete("{id}")]
    public virtual async Task<ActionResult> Delete(int id)
    {
        await _service.DeleteAsync(id);
        return NoContent();
    }

    [HttpGet("lookup")]
    public virtual async Task<ActionResult<List<LookupResponse>>> GetLookup()
        => Ok(await _service.GetLookupAsync());
}
