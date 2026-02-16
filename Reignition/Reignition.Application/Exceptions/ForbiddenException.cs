namespace Reignition.Application.Exceptions;

public class ForbiddenException : Exception
{
    public ForbiddenException(string message = "Nemate dozvolu za ovu akciju.") : base(message) { }
}
