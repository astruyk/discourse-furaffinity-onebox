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
			titleElement = doc.css("meta[property='twitter:title']")
			descriptionElement = doc.css("meta[property='twitter:description']");
			imageElement = doc.css("meta[property='twitter:image']");

			if !titleElement.nil?
				# Most pages (even the NSFW blocked ones) will have this. If not, we're not on a FA page we can do anything
				# useful with.
				title = titleElement["content"];
				html.push("<a class=\"fa_title\" href=\"#{@url}\">#{title}</a>");
				html.push("<br/>");

				if !imageElement.nil?
					imageUrl = imageElement["content"];
					html.push("<a href=\"#{@url}\"><img src=\"#{imageUrl}\" /></a>");
					html.push("<br/>");
				end

				if !descriptionElement.nil?
					description = descriptionElement["content"];
					html.push("<p class=\"fa_description\">#{description}</p>");
				end
			else
				# We can't do anything useful here. Just bail and let someone else try.
				return nil;
			end
		rescue StandardError => error
			html.push(error.message);
			html.push("<br/><br/>");
			html.push(error.backtrace);
		end
		html.push("</div>");
		html.join('');
	end
end
