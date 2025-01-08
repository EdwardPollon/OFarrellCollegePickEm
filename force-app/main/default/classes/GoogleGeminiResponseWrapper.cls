public class GoogleGeminiResponseWrapper {

	public cls_candidates[] candidates;
	public cls_usageMetadata usageMetadata;
	public String modelVersion;	//gemini-1.5-flash

	public class cls_candidates {
		public cls_content content;
		public String finishReason;	//STOP
		public cls_citationMetadata citationMetadata;
		public Double avgLogprobs;	//-0.1525533756096206
	}

	public class cls_content {
		public cls_parts[] parts;
		public String role;	//model
	}

	public class cls_parts {
		public String text;	//Sample returned response
	}

	class cls_citationMetadata {
		public cls_citationSources[] citationSources;
	}

	class cls_citationSources {
		public Integer startIndex;	//289
		public Integer endIndex;	//422
		public String uri;	//https://www.deskera.com/blog/ai-automation-procurement/
	}

	class cls_usageMetadata {
		public Integer promptTokenCount;	//4
		public Integer candidatesTokenCount;	//668
		public Integer totalTokenCount;	//672
	}

	public static GoogleGeminiResponseWrapper parse(String json){
		return (GoogleGeminiResponseWrapper) System.JSON.deserialize(json, GoogleGeminiResponseWrapper.class);
	}
}