using System.Text.Json.Serialization;

namespace Microsoft.Azure.Samples.Functions;

/// <summary>
/// Represents the input document.
/// </summary>
public class InputDocument
{
    /// <summary>
    /// Gets or sets the list of requests.
    /// </summary>
    [JsonPropertyName("requests")]
    public List<string>? Requests { get; set; }
}