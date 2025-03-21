using System.Text.Json.Serialization;

namespace Microsoft.Azure.Samples.Functions;

/// <summary>
/// Represents a result.
/// </summary>
public class OutputDocument : Entity
{
    /// <summary>
    /// Creates an instance of the prompt class.
    /// </summary>
    public OutputDocument() : base() { }

    /// <summary>
    /// Gets or sets the request prompt.
    /// </summary>
    [JsonPropertyName("request")]
    public string? Request { get; set; }

    /// <summary>
    /// Gets or sets the response prompt.
    /// </summary>
    [JsonPropertyName("response")]
    public string? Response { get; set; }
}