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
		imageUrl = "https://www.furaffinity.net/themes/classic/img/banners/fa_logo.png";
		iconUrl = "https://www.furaffinity.net/themes/classic/img/favicon.ico";

		begin
			pageContents = open(@url);
			doc = Nokogiri::HTML(pageContents);
			titleElements = doc.css("meta[property='og:title']");
			if !titleElements.blank?
				title = titleElements[0]["content"];
			end

			descriptionElements = doc.css("meta[property='og:description']");
			if !descriptionElements.blank?
				description = descriptionElements[0]["content"];
			end

			# We're using the actual source image here (not the og:image value) because
			# FA's hotlinking protection causes us to generate 403 errors if we try to
			# call it with those default values w/o actually visiting the link in a real
			# browser first. Thanks FA.
			# imageElements = doc.css("meta[property='og:image:secure_url]");
			mimeType = "img/jpeg";
			imgBase64 = "";
			if !imageElements.blank?
				imageUrl = imageElements[0]["content"];
				imageUrl = imageUrl.sub("@800-", "@100-");
				imgBase64 = imageUrl;

				# Actually try to open the URL so that the thumbnail will be generated (if it isn't already).
				# Use headers ripped from a normal browser session so that it won't trigger the hotlinking errors.
				# imgData = open(imageUrl,
				# 		"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
				# 		"Accept-Encoding" => "gzip, deflate",
				# 		"Accept-Language" => "n-GB,en-US;q=0.9,en;q=0.8",
				# 		"Connection" => "keep-alive",
				# 		"Host" => "d.facdn.net",
				# 		"Upgrade-Insecure-Requests" => "1",
				# 		"User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36"
				# 	);
				# mimeType = imgData.content_type;
				# imgBase64 = ::Base64.encode64(imgData.read);				
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
					<img src="data:#{mimeType};base64,#{imgBase64}" />
					<h3><a href="#{linkUrl}" target="_blank" rel="nofollow noopener">#{title}</a></h3>
					<p>#{description}</p>
					<div style="clear: both"></div>
				</article>
        	</aside>
        HTML
	end
end