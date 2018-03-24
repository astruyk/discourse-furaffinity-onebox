# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::TwitchStreamOnebox
	include Onebox::Engine::StandardEmbed

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX
	
	def to_html
		html = [];
		html.push("<div class=\"fa_container\" >");
		begin
			og = get_opengraph;
			title = og[:title];
			description = og[:description];

			# Note: The name in this URL has to match the name declared at the top of this file.
			imageUrl = og[:image] || "/plugins/discourse-furaffinity-onebox/images/fa_logo.png";

			# Don't generate an 800px image, generate a smaller one.
			imageUrl.sub("@800-", "@400-");

			# Most pages (even the NSFW blocked ones) will have this.
			# If not, we're not on a FA page we can do anything
			# useful with and we can just bail.
			html.push("<a href=\"#{@url}\">");
			if !title.nil?
				html.push("<div class=\"fa_title\">");
				html.push(title);
				html.push("</div>");
			end

			html.push("<div class=\"fa_image\">")
			html.push("<img src=\"#{imageUrl}\" />");
			html.push("</div>");

			if description.nil?
				html.push("<div class=\"fa_description\">");
				html.push(description);
				html.push("</div>");
			end

			if og[:image].nil?
				html.push("<div class=\"fa_nsfw_warning\">");
				html.push("(The image preview could not be retrieved, most likely because it is adult-only)");
				html.push("</div>");
			end

			html.push("</a>");
		rescue StandardError => error
			html.push("<pre>");
			html.push(error.message);
			html.push("<br/><br/>");
			html.push(error.backtrace);
			html.push("</pre>");
		end
		html.push("</div>");
		html.join('');
	end
end
