using Reignition.Application.DTOs.Request;
using Reignition.Application.DTOs.Response;
using Reignition.Application.Filters;

namespace Reignition.Application.IServices;

public interface IPaymentService
    : IBaseService<PaymentResponse, CreatePaymentRequest, UpdatePaymentRequest, PaymentQueryFilter>
{
}
