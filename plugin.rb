# name: discourse-furaffinity-onebox
# about: Adds support for properly embedding Furaffinity submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-furaffinity-onebox

register_asset "styles.css"

# Onebox for Furaffinity submissions.
class Onebox::Engine::FuraffinityOnebox
	include Onebox::Engine

	# Example submission URL is https://www.furaffinity.net/view/10235836/
	REGEX = /^https?:\/\/(?:www\.)?furaffinity\.net\/view\/([0-9]{4,25})(?:\/)?$/
	matches_regexp REGEX

	def to_html
		doc = Nokogiri::HTML(open(@url));
		titleElements = doc.css("meta[name='twitter:title']");
		descriptionElements = doc.css("meta[name='twitter:description']");
		imageElements = doc.css("meta[name='twitter:image']");

		// TODO escape url?
		linkUrl = @url;
		title = "TITLE";
		description = "SOMETHING DESCRIPTION";
		imageUrl = "IMAGEURL";

		<<-HTML
			<aside class="onebox whitelistedgeneric">
				<header class="source">
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