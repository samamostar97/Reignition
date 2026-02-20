using Microsoft.AspNetCore.Authorization;
using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Filters;
using Reignition.Application.IServices;

namespace Reignition.API.Controllers;

[Authorize(Roles = "Admin")]
public class PaymentsController
    : BaseController<PaymentResponse, CreatePaymentRequest, UpdatePaymentRequest, PaymentQueryFilter>
{
    public PaymentsController(IPaymentService service) : base(service) { }
}
