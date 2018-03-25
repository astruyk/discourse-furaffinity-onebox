# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::TwitchStreamOnebox
	include Onebox::Engine

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX
	
	def to_html
		html = [];
		html.push("<div class=\"fa_container\" >");
		begin
			doc = Nokogiri::HTML(open(@url));
            titleElements = doc.css("meta[name='twitter:title']");
            descriptionElements = doc.css("meta[name='twitter:description']");
            imageElements = doc.css("meta[name='twitter:image']");

			# Most pages (even the NSFW blocked ones) will have this.
			# If not, we're not on a FA page we can do anything
			# useful with and we can just bail.
			if !titleElements.blank?
				title = titleElements[0]["content"];
				html.push("<a href=\"#{@url}\">");
				html.push("<div class=\"fa_title\">");
				html.push(title);
				html.push("</div>");

				# Note: The name in this URL has to match the name declared at the
				# top of this file.
				imageUrl = "/plugins/discourse-furaffinity-onebox/images/fa_logo.png";
				if !imageElements.blank?
					# If we have a better URL for the image, it must be SFW. Use it.
					imageUrl = imageElements[0]["content"];
					imageUrl.sub("@800-", "@400-");
				end
				imageUrl = ::Onebox::Helpers.normalize_url_for_output(imageUrl);
				html.push("<div class=\"fa_image\">")
				html.push("<img src=\"#{imageUrl}\" />");
				html.push("</div>");

				if !descriptionElements.blank?
					description = descriptionElements[0]["content"];
					html.push("<div class=\"fa_description\">");
					html.push(description);
					html.push("</div>");
				end

				if imageElements.blank?
					html.push("<div class=\"fa_nsfw_warning\">");
					html.push("(The image preview could not be retrieved, most likely because it is adult-only)");
					html.push("</div>");
				end

				html.push("</a>");
			else
				# Bail! Nothing we can do. Maybe someone else can generate something useful for this.
				return;
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
