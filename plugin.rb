# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.2
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
		err_title = "";
		err_body = "";

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
				
				# Attempt to bypass FA being unpleasent by reading the thumbnail image now.
				# SOMETIMES this gets it generated before we link it, so that it will show
				# up. Other times, FA decides not to play nice and doesn't let us hotlink it.
				begin
					response = Onebox::Helpers::fetch_response(thumbnailUrl, nil, nil, {"Referer" => "http://www.furaffinity.net" });
					begin
						response = Onebox::Helpers::fetch_response(thumbnailUrl, nil, nil, {"Referer" => Discourse.base_url });
						imageSrc = thumbnailUrl;
					rescue Net::HTTPServerException => err
						# FA decided not to let us link this thumbnail. Bleh.
						# Use the default logo image.
						err_title = err.message;
						err_body = err.backtrace.join("\n");
					end
				rescue Net::HTTPServerException => err
					# FA failed to generate the thumbnail, even for itself.
					# Use the default logo image.
					err_title = err.message;
					err_body = err.backtrace.join("\n");
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
					<p hidden><h3>#{err_title}</h3><pre>#{err_body}</pre></p>
					<div style="clear: both"></div>
				</article>
        	</aside>
        HTML
	end
end