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
		doc = Nokogiri::HTML(open(@url));
		title = doc.css("title")[0].text;
		html = [];
		html.push("<div class=\"fa_container\" >");
		html.push(title);
		html.push("</div>");
		html.join('');
	end
end
