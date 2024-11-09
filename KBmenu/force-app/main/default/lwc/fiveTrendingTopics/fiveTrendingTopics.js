import { LightningElement, api, wire, track } from 'lwc';
import getMostViewedArticles from '@salesforce/apex/FiveTrendingTopicsClass.getMostViewedArticles';
import customStyle from './fiveTrendingTopicsStyle.css';

export default class FiveTrendingTopics extends LightningElement {
	@api cardTitle = 'Trending Topics'; // Default title
	@track articles;
	@track error;

	@wire(getMostViewedArticles)
	wiredArticles({ error, data }) {
		//console.log("data", JSON.stringify(data));
		//console.log("error", JSON.stringify(error));
	   	if(data) {
	       	this.articles = data.map(article => ({
                ...article,
                articleUrl: this.constructArticleUrl(article.UrlName),
            }));
	       	this.error = undefined;
	   	} else if (error) {
	       	this.error = error;
	       	this.articles = undefined;
	   	}
	}

	// Getter function to construct the full URL for an article
    get articleUrls() {
        return this.articles ? this.articles.map(article => this.constructArticleUrl(article.UrlName)) : [];
    }

    // Method to construct the full URL for an article
    constructArticleUrl(articleUrlName) {
        // Get the base URL from the $Label global variable
        const baseUrl = 'https://help.automai.com/s/article';

        // Construct the full URL
        return `${baseUrl}/${articleUrlName}`;
    }

	static stylesheets = [customStyle];
}