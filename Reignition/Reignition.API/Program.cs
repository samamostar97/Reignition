using Microsoft.EntityFrameworkCore;
using Reignition.API.Extensions;
using Reignition.API.Middleware;
using Reignition.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddInfrastructure(builder.Configuration)
    .AddJwtAuthentication(builder.Configuration)
    .AddSwaggerWithAuth()
    .AddControllers();

var app = builder.Build();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ReignitionDbContext>();
    await context.Database.MigrateAsync();
    await SeedService.SeedAsync(context);
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ExceptionHandlerMiddleware>();
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
