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
			html.push(downloadLinks.to_s);
			html.push("<br/>");
			html.push("<br/>");
			if downloadLinks.blank?
				html.push("Failed to extract image from submission, so here's the link instead.");
				html.push("<br/>");
				html.push("<br/>");
				html.push("<a href=\"#{@url}\">#{@url}</a>");
			else
				downloadLink = downloadLinks[0]["href"];
				html.push("<a href=\"#{@url}\">");
				html.push("<img src=\"#{downloadLink}\" />");
				html.push("</a>");
				html.push("<br />");
				html.push("<span>XXX by yyy</span>");
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
