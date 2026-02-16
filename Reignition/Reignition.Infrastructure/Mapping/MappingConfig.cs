using Mapster;
using Reignition.Application.DTOs.Response;
using Reignition.Core.Entities;

namespace Reignition.Infrastructure.Mapping;

public static class MappingConfig
{
    public static void Configure()
    {
        TypeAdapterConfig.GlobalSettings.Default
            .IgnoreNullValues(true);

        TypeAdapterConfig<Membership, MembershipResponse>.NewConfig()
            .Map(dest => dest.UserFullName, src => src.User.FirstName + " " + src.User.LastName)
            .Map(dest => dest.MembershipTypeName, src => src.MembershipType.Name);
    }
}
