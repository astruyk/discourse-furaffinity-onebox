# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::FuraffinityOnebox
	include Onebox::Engine
	include Onebox::LayoutSupport
	include Onebox::HTML

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX
	
	def data
		titleElements = raw.css("meta[name='twitter:title']");
		descriptionElements = raw.css("meta[name='twitter:description']");
		imageElements = raw.css("meta[name='twitter:image']");

		titleText = "Loading Failed";
		imageUrl = "/plugins/discourse-furaffinity-onebox/images/fa_logo.png";
		descriptionText = "The image preview could not be retrieved, most likely because it is adult-only";

		if !titleElements.blank?
			titleText = titleElements[0]["content"];
		end
		
		if !imageElements.blank?
			imageUrl = imageElements[0]["content"];
		end

		if !descriptionElements.blank?
			descriptionText = descriptionElements[0]["content"];
		end

		{
			link: @url,
			title: titleText,
			image: imageUrl,
			description: descriptionText
		}
	end
end
