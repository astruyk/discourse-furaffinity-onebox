# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::FuraffinitySubmissionOnebox
	include Onebox::Engine

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX

	def to_html
		linkUrl = @url;
		title = "FurAffinity Submission";
		description = "";
		imageUrl = "https://www.furaffinity.net/themes/classic/img/banners/fa_logo.png";
		iconUrl = "https://www.furaffinity.net/themes/classic/img/favicon.ico";

		begin
			doc = Nokogiri::HTML(open(@url));
			titleElements = doc.css("meta[property='og:title']");
			if !titleElements.blank?
				title = titleElements[0]["content"];
			end

			descriptionElements = doc.css("meta[property='og:description']");
			if !descriptionElements.blank?
				description = descriptionElements[0]["content"];
			end

			# We're using the secure_url here because that is only present for SFW posts.
			# On NSFW posts the og:image tag is a relative link to the fa_logo.png
			# which we already have as an absolute URL as the default. If we use the relative
			# URL here, we'd have to mangle it (append the domain) to get it back to something
			# we can use in an <img> element.
			imageElements = doc.css("#submissionImg");
			if !imageElements.blank?
				# This image should be the thumbnail that would be generated for the preview.
				# We want to use that because using a non-existing thumbnail size (i.e. the
				# '@800-' size thumbnail returned by the normal 'og:image' attribute) might not
				# exist yet and using our agent will trigger the hotlinking protection and error.
				imageUrl = "https://www.furaffinity.net" + imageElements[0]["data-preview-src"];
			end
		rescue StandardError => err
			title = "Error";
			description = err.message + "\n\n" + err.backtrace;
		end

		<<-HTML
			<aside class="onebox whitelistedgeneric">
				<header class="source">
					<img src="#{iconUrl}" class="site-icon" style="width: 16px; height: 16px" >
					<a href="#{linkUrl}" target="_blank" rel="nofollow noopener">furAffinity.net</a>
				</header>
				<article class="onebox-body">
					<img src="#{imageUrl}" class="thumbnail size-resolved" />
					<h3><a href="#{linkUrl}" target="_blank" rel="nofollow noopener">#{title}</a></h3>
					<p>#{description}</p>
					<div style="clear: both"></div>
				</article>
        	</aside>
        HTML
	end
end