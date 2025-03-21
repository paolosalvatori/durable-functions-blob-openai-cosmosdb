using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Azure.Functions.Worker.Extensions.OpenAI.TextCompletion;

namespace Microsoft.Azure.Samples.Functions;

public static class PromptProcessor
{
    /// <summary>
    /// Processes the input document received by the blob trigger from the specified storage account.
    /// </summary>
    /// <param name="stream"></param>
    /// <param name="name"></param>
    /// <param name="client"></param>
    /// <param name="context"></param>
    /// <returns>Task</returns>
    [Function(nameof(ProcessDocument))]
    public static async Task ProcessDocument([BlobTrigger("input/{name}", Connection = "STORAGE_ACCOUNT")] Stream stream,
        string name,
        [DurableClient] DurableTaskClient client,
        FunctionContext context)
    {
        // Create a new instance of the logger
        ILogger logger = context.GetLogger(nameof(ProcessDocument));


        // Check that the stream is not null of empty
        if (stream == null || stream.Length == 0)
        {
            logger.LogError($"[ProcessDocument] Received [{name}] blob is empty or null.");
            return;
        }

        // Initialize the JSON string to empty
        string json = string.Empty;

        // Read the JSON from the stream
        using var blobStreamReader = new StreamReader(stream);
        {
            json = await blobStreamReader.ReadToEndAsync();
        }

        // Check that the JSON is not null or empty
        if (string.IsNullOrEmpty(json))
        {
            logger.LogError($"[RunOrchestrator] Received [{name}] blob is empty or invalid.");
            return;
        }

        // Deserialize the JSON into an InputDocument
        InputDocument? document = JsonSerializer.Deserialize<InputDocument>(json);

        // Check that the document is not null or empty
        if (document == null || document.Requests == null)
        {
            logger.LogError($"[ProcessDocument] Received [{name}] blob is empty or invalid.");
            return;
        }

        // Start a new orchestration instance
        string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(nameof(RunOrchestrator), document);
    }

    /// <summary>
    /// Orchestrates the processing of the input document.
    /// </summary>
    /// <param name="context"></param>
    /// <param name="document"></param>
    /// <returns>Task</returns>
    [Function(nameof(RunOrchestrator))]
    public static async Task RunOrchestrator([OrchestrationTrigger] TaskOrchestrationContext context, InputDocument document)
    {
        // Create a new instance of the logger
        ILogger logger = context.CreateReplaySafeLogger(nameof(RunOrchestrator));


        // Validate input
        if (document == null || document.Requests == null || document.Requests.Count == 0)
        {
            logger.LogError("[RunOrchestrator] Received invalid document.");
            return;
        }

        // Process each request in the document
        foreach (var request in document.Requests)
        {
            try
            {
                string response = await context.CallActivityAsync<string>(nameof(AnswerRequest), request);

                if (string.IsNullOrEmpty(response))
                {
                    logger.LogError($"[RunOrchestrator] Failed to process [{request}] request.");
                    continue;
                }

                // Save the response
                await context.CallActivityAsync(nameof(SaveResponse), new OutputDocument { Request = request, Response = response });
            }
            catch (Exception ex)
            {
                logger.LogError(ex, $"[RunOrchestrator] An exception occurred while processing [{request}] request: [{ex.Message}].");
            }
        }
    }

    /// <summary>
    /// Answers the specified request using the indicated chat model of the specified Azure OpenAI Service.
    /// </summary>
    /// <param name="request"></param>
    /// <param name="response"></param>
    /// <param name="executionContext"></param>
    /// <returns>The response prompt from Azure OpenAI Service</returns>
    [Function(nameof(AnswerRequest))]
    public static string AnswerRequest(
            [ActivityTrigger] string request, 
            [TextCompletionInput("{request}", Model = "%CHAT_MODEL_DEPLOYMENT_NAME%")] TextCompletionResponse response,
            FunctionContext executionContext
        )
    {
        // Create a new instance of the logger
        ILogger logger = executionContext.GetLogger(nameof(AnswerRequest));

        // Log the request
        logger.LogInformation($"[AnswerRequest]\nRequest:\n{request}\nResponse:\n{response.Content}");
        return response.Content;
    }

    /// <summary>
    /// Saves the response to the specified document.
    /// </summary>
    /// <param name="document"></param>
    /// <param name="executionContext"></param>
    /// <returns>The output document to save to Azure Cosmos DB.</returns>
    [Function(nameof(SaveResponse))]
    [CosmosDBOutput("%COSMOS_DB_DATABASE%", "%COSMOS_DB_CONTAINER%", Connection = "COSMOS_DB_CONNECTION", CreateIfNotExists = true)]
    public static OutputDocument? SaveResponse([ActivityTrigger] OutputDocument document, FunctionContext executionContext)
    {
        // Create a new instance of the logger
        ILogger logger = executionContext.GetLogger(nameof(SaveResponse));

        // Validate input document
        if (document == null || string.IsNullOrEmpty(document.Request) || string.IsNullOrEmpty(document.Response) || string.IsNullOrEmpty(document.Id))
        {
            logger.LogError("[SaveResponse] Received invalid document.");
            return null;
        }

        // Log the operation
        logger.LogInformation($"[SaveResponse] Saved [{document.Id}] response.");
        return document;
    }
}
