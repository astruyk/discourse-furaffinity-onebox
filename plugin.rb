# name: Discourse FurAffinity Onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: tfProxy
# url: https://github.com/tfProxy/discourse-furaffinity-onebox

# Register stylesheet for our custom classes
register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::TwitchStreamOnebox
	include Onebox::Engine

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX

	def submissionId
		@url.match(REGEX)[1]
	end
	
	def to_html
		html = [];
		html.push("<div class=\"fa_container\" >");
		begin
			doc = Nokogiri::HTML(open(@url));
			doc.remove_namespaces!
			title = doc.css("title")[0].text;
			downloadLinks = doc.xpath("//a[contains(text(), 'Download')]");
			#submissionAuthor = doc.css("...");
			#submissionTitle = doc.css("...")
			html.push(title);
			html.push("<br/>");
			html.push(@url);
			html.push("<br/>");
			if downloadLinks.blank?
				downloadLink = downloadLinks[0]["href"];
				html.push("URL: #{downloadLink}");
			else
				html.push("Furaffinity: <a href=\"#{@url}\">#{@url}</a>");
			end
			
			#html.push("<a href=\"#{submissionUrl}\">");
			#html.push("<img src=\"#{submissionUrl}\" />");
			#html.push("<br/>");
			#html.push(submissionUrl);
			#html.push("</a>");
		rescue StandardError => error
			html.push(error.message);
			html.push("<br/>");
			html.push(error.backtrace);
		end
		html.push("</div>");
		html.join('');
	end
end
