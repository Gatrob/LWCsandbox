import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getKnowledgeDataCategories from '@salesforce/apex/CategoryListingClass.getKnowledgeDataCategories';
import { CurrentPageReference } from 'lightning/navigation';

const ARTICLES_PER_PAGE = 10;

export default class CategoryList extends NavigationMixin(LightningElement) {
    @track categories;
    @track articles;
    @track categoryName;
    @track categoryGroupName;
    @track currentPage = 1;
    @track totalArticles;

    currentPageReference = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.categoryGroupName = currentPageReference.state.group;
            this.categoryName = currentPageReference.state.name;
        }
    }

    @wire(getKnowledgeDataCategories, { categoryName: '$categoryName', categoryGroupName : '$categoryGroupName', pageNumber: '$currentPage' })
    wiredData({ error, data }) {
        if (data) {
            console.log('data: ', data);
            //this.categories = data.childCategories;
            this.articles = data.articleList.map(article => ({
                ...article,
                articleUrl: this.constructArticleUrl(article.UrlName),
                // trimmedDescription: this.trimContent(article.Description),
                // trimmedContent: this.trimContent(article.Content),
                // trimmedAnswer: this.trimContent(article.Answer),
            }));
            this.totalArticles = data.totalArticles;
        } else if (error) {
            console.log('error: ', error);
        }
    }

    handleLoadMore() {
        if (this.currentPage * ARTICLES_PER_PAGE < this.totalArticles) {
            this.currentPage++;
            getKnowledgeDataCategories({
                categoryName: this.categoryName,
                categoryGroupName: this.categoryGroupName,
                pageNumber: this.currentPage,
            })
            .then((data) => {
                // Update articles and total articles
                this.articles = data.articleList;
                this.totalArticles = data.totalArticles;
            })
            .catch((error) => {
                console.error('Error loading next page:', error);
            });
        } else {
            console.log('All articles have been loaded.');
            // Disable the button or display a message
        }
    }

    // trimContent(content) {
    //     const maxLength = 50; // Set your desired maximum length
    //     return content && content.length > maxLength
    //         ? content.substring(0, maxLength) + '...'
    //         : content;
    // }

    // Getter function to construct the full URL for an article
    get articleUrls() {
        return this.articles ? this.articles.map(article => this.constructArticleUrl(articleList.UrlName)) : [];
    }

    // Method to construct the full URL for an article
    constructArticleUrl(articleUrlName) {
        // Get the base URL from the $Label global variable
        const baseUrl = 'https://help.automai.com/s/article';

        // Construct the full URL
        return `${baseUrl}/${articleUrlName}`;
    }

    handleCategoryClick(event) {
        const selectedCategory = event.target.textContent;

        // Navigate to the category detail page with the selected category as a parameter
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/s/category?name=${selectedCategory}`
            }
        });
    }
}