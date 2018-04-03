# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

require 'base64'

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
		imageSrc = "https://www.furaffinity.net/themes/classic/img/banners/fa_logo.png";
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

			imageElements = doc.css("meta[property='og:image:secure_url']");
			if !imageElements.blank?
				# Try to down-size the default thumbnail size (800px) to something
				# more reasonable, since we're not embedding the whole image anyway.
				thumbnailUrl = imageElements[0]["content"].sub("@800-", "@200-");

				# Read the data from the URL. This prevents images that haven't been visited
				# in a long time from showing up as broken links. FA is doing some kind of crazy
				# server-side caching for thumbnails and not generating them when requested by
				# an <img /> element (returning 407 errors instead), it works if someone
				# visits the URL and pulls the actual image data though... 
				# This seems like a bug with their hotlinking protection because they actaully
				# embedd this metadata for tools to use as thumbnails. Lousy.
				begin
					imageBase64Data = ::Base64.encode64(
						open(thumbnailUrl,
						"User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36",
						"Referer" => ""
						) { |io| io.read });
					imageSrc = thumbnailUrl;
				rescue StandardError => err
					# Assuming the error came from reading the data, just use the default FA URL
					# and surpress the error.
				end
			end
		rescue StandardError => err
			title = "Error";
			description = err.message + "\n\n" + "<pre>" + err.backtrace.join("\n") + "</pre>";
		end

		<<-HTML
			<aside class="onebox whitelistedgeneric">
				<header class="source">
					<img src="#{iconUrl}" class="site-icon" style="width: 16px; height: 16px" >
					<a href="#{linkUrl}" target="_blank" rel="nofollow noopener">furAffinity.net</a>
				</header>
				<article class="onebox-body">
					<img src="#{imageSrc}" class="thumbnail" referrerpolicy="no-referrer" />
					<h3><a href="#{linkUrl}" target="_blank" rel="nofollow noopener">#{title}</a></h3>
					<p>#{description}</p>
					<div style="clear: both"></div>
				</article>
        	</aside>
        HTML
	end
end