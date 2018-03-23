# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: tfProxy
# url: https://github.com/tfProxy/discourse-furaffinity-onebox

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
			doc.remove_namespaces!;

			titleElements = doc.css("meta[name='twitter:title']");
			descriptionElements = doc.css("meta[name='twitter:description']");
			imageElements = doc.css("meta[name='twitter:image']");

			# Most pages (even the NSFW blocked ones) will have this.
			# If not, we're not on a FA page we can do anything
			# useful with and we can just bail.
			if !titleElements.blank?
				title = titleElements[0]["content"];
				html.push("<div class=\"fa_title\">")
				html.push("<a href=\"#{@url}\">#{title}</a>");
				html.push("</div>");

				# Note: The name in this URL has to match the name declared at the
				# top of this file.
				imageUrl = "/plugins/discourse-furaffinity-onebox/images/fa_logo.png";

				# If we have a better URL for the image, it must be SFW. Use it.
				if !imageElements.blank?
					imageUrl = imageElements[0]["content"];
				end
				html.push("<div class=\"fa_image\">")
				html.push("<a href=\"#{@url}\"><img src=\"#{imageUrl}\" /></a>");
				html.push("</div>");

				if !descriptionElements.blank?
					description = descriptionElements[0]["content"];
					html.push("<div class=\"fa_description\">");
					html.push(description);
					html.push("</div>");
				end

				if imageElements.blank
					# Assuming the image is NSFW here...
					html.push("<div class=\"fa_nsfw_warning\">");
					html.push("This image is only visible for people who are logged in to FA so it could not be retrieved. Likely it is NSFW.");
					html.push("</div>");
				end
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
