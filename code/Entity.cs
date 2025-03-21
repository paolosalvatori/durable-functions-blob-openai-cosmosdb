using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Microsoft.Azure.Samples.Functions;

/// <summary>
/// Abstract class that represents an entity in the system.
/// </summary>
public abstract class Entity
{
    #region Public Constructor
    /// <summary>
    /// Creates an instance of the entity class.
    /// </summary>
    public Entity() {}
    #endregion

    /// <summary>
    /// Gets or sets the unique identifier of the document/object.
    /// </summary>
    [Key]
    [Required]
    [JsonPropertyName("id")]
    public string Id { get; set; } = Guid.NewGuid().ToString();

    /// <summary>
    /// Gets or sets the date and time the document/object was created.
    /// </summary>
    [JsonPropertyName("createdUtc")]
    public DateTime CreatedUtc { get; set; } = DateTime.UtcNow;
}
