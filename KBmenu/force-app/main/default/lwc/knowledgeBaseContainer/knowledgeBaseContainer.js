import { LightningElement, track } from 'lwc';
import getArticleByTitle from '@salesforce/apex/KnowledgeArticleController.getArticleByTitle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KnowledgeBaseContainer extends LightningElement {
    @track selectedArticleContent = '';
    @track selectedArticleTitle = '';
    @track isMenuVisible = true;
    @track isUsersAndRoles = false;
    @track articleContentItems = [];

    // State variables for submenu expansion
    @track isSetupConfigExpanded = false;
    @track isDirectorConfigExpanded = false;
    @track isAutomaiWatcherExpanded = false;
    @track isAutomaiLoaderExpanded = false;
    @track isAutomaiTesterExpanded = false;
    @track isAutomaiWorkerExpanded = false;
    @track isBotManagerExpanded = false;
    @track isBotManagerInstallationExpanded = false;

    // Getter methods for icon names
    get setupConfigIconName() {
        return this.isSetupConfigExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get directorConfigIconName() {
        return this.isDirectorConfigExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get botManagerIconName() {
        return this.isBotManagerExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get botManagerInstallationIconName() {
        return this.isBotManagerInstallationExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get automaiWatcherIconName() {
        return this.isAutomaiWatcherExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get automaiLoaderIconName() {
        return this.isAutomaiLoaderExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get automaiTesterIconName() {
        return this.isAutomaiTesterExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get automaiWorkerIconName() {
        return this.isAutomaiWorkerExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get isAutomaiWatcherArticle() {
        return this.selectedArticleTitle === 'Automai Watcher';
    }
    
    // Strip out the original note section from the article content
    get formattedArticleContent() {
        if (!this.selectedArticleContent) return '';
        
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = this.selectedArticleContent;
        
        // Remove all instances of note sections
        const noteSections = tempDiv.querySelectorAll('.note, [class*="note"], .custom-note');
        noteSections.forEach(note => note.remove());
        
        return tempDiv.innerHTML;
    }

       

    // Method to toggle the side menu
    toggleMenu() {
        this.isMenuVisible = !this.isMenuVisible;
        const containerElement = this.template.querySelector('.container');
        if (containerElement) {
            containerElement.classList.toggle('menu-hidden');
        }
    }

    // Method to toggle submenu visibility dynamically
    toggleSubmenu(event) {
        const submenu = event.currentTarget.dataset.submenu;
        this[submenu] = !this[submenu];
    }

    // Handle clicks on the menu items
    handleMenuClick(event) {
        event.preventDefault();
        const tab = event.currentTarget.dataset.tab;

        const customTitles = {
            // Existing mappings
            usersAndRoles: 'User Roles and Group Permissions',
            computeOptimized: 'Compute Optimized',
            setup: 'Setup and configuration',
            overview: 'Overview',
            // Director configuration submenu items
            directorConfiguration: 'Director Configuration',
            directorConfigurationsProperties: 'Director configurations: Properties',
            tasks: 'Director configurations: Tasks',
            users: 'Director configurations: Users',
            rolesPermissions: 'Director configurations: Roles/Permissions',
            groupsDepartments: 'Director configurations: Departments',
            loadBalancing: 'Director configurations: Load Balance',
            // BotManager submenu items
            
            botmanagerGettingStarted: 'BotManager: Getting Started',
            botmanagerAdvanced: 'BotManager: Advanced Configuration',
            // Other mappings
            profileAndResource: 'Profile Menu',
            directorLogs: 'Director Logs',
            botmanager: 'BotManager',
            events: 'Director: Events and Notifications',
            report: 'Reports',
            directorProjects: 'Director: Projects',
            directorSchedules: 'Director: Schedules',
            // Automai Watcher submenu items
            automaiWatcher: 'Automai Watcher',
            automaiWatcherDashboard: 'Automai Watcher: Dashboard',
            processMonitor: 'Automai Watcher: Process Monitors',
            automaiWatcherReports: 'Automai Watcher: Reports',
            rWatchers: 'Automai Watcher: rWatchers',
            // Automai Loader submenu items
            automaiLoader: 'Automai Loader',
            automaiLoaderDashboard: 'Automai Loader: Dashboard',
            testPlan: 'Automai Loader: Test Plans',
            testRuns: 'Automai Loader: Test Runs',
            alBotManagers: 'Automai Loader: BotManagers',
            // Automai Tester submenu items
            automaiTester: 'Automai Tester',
            automaiTesterDashboard: 'Automai Tester: Dashboard',
            automaiTesterTestPlan: 'Automai Tester: Test Plans',
            automaiTesterTestRuns: 'Automai Tester: Test Runs',
            rTesters: 'Automai Tester: rTesters',
            // Automai Worker submenu items
            automaiWorker: 'Automai Worker',
            automaiWorkerDashboard: 'Automai Worker: Dashboard',
            processFlows: 'Automai Worker: Process Flows',
            automaiWorkerReports: 'Automai Worker: Reports',
            rWorkers: 'Automai Worker: rWorkers',
            
        };

        let articleTitle = customTitles[tab] || tab.charAt(0).toUpperCase() + tab.slice(1);

        // Set isUsersAndRoles to true when the corresponding tab is clicked
        this.isUsersAndRoles = (tab === 'usersAndRoles');

        // Fetch the article content for the selected tab and update the content
        this.fetchArticleContent(articleTitle);
    }

    

    // Handle note link clicks with scroll behavior
    handleNoteClick(event) {
        event.preventDefault();
        const tab = event.currentTarget.dataset.tab;
        
        // First update the content
        this.handleMenuClick(event);
        
        // Then scroll to top after content is updated
        Promise.resolve().then(() => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
            
            // Also ensure the content div itself is scrolled to top
            const contentDiv = this.template.querySelector('.content');
            if (contentDiv) {
                contentDiv.scrollTop = 0;
            }
        });
    }

    // Fetch the article content
    fetchArticleContent(articleTitle) {
        console.log('Fetching article:', articleTitle);
        getArticleByTitle({ title: articleTitle })
            .then(result => {
                if (!result) return;
                
                this.selectedArticleTitle = result.Title;
                const cleanContent = this.cleanHTML(result.Content__c);
                
                // Insert content using querySelector
                const contentDiv = this.template.querySelector('.article-content');
                if (contentDiv) {
                    contentDiv.innerHTML = cleanContent;
                    
                    // Add click listeners to details/summary elements
                    const details = contentDiv.querySelectorAll('details');
                    details.forEach(detail => {
                        detail.addEventListener('click', (event) => {
                            event.preventDefault();
                            const summary = detail.querySelector('summary');
                            if (summary === event.target) {
                                detail.open = !detail.open;
                            }
                        });
                    });
                }
            })
            .catch(error => {
                console.error('Error fetching article:', error);
                const errorMessage = error.body?.message || error.message || 'Unknown error occurred';
                const contentDiv = this.template.querySelector('.article-content');
                if (contentDiv) {
                    contentDiv.innerHTML = `Unable to load content: ${errorMessage}`;
                }
                this.showToast('Error', errorMessage, 'error');
            });
    }

    // Function to clean up the HTML
    cleanHTML(content) {
        if (!content) return '';
        
        const div = document.createElement('div');
        div.innerHTML = content;
        
        // Remove unwanted elements
        div.querySelectorAll('div.background-image-overlay, footer, .footer').forEach(node => node.remove());
        
        // Preserve list formatting
        const lists = div.querySelectorAll('ol, ul');
        lists.forEach(list => {
            // Ensure ordered lists have numbers
            if (list.tagName === 'OL') {
                list.style.listStyleType = 'decimal';
            }
            // Ensure unordered lists have bullets
            else if (list.tagName === 'UL') {
                list.style.listStyleType = 'disc';
            }
            
            // Ensure proper indentation
            list.style.paddingLeft = '40px';
            list.style.marginBottom = '1em';
            
            // Style list items
            const items = list.querySelectorAll('li');
            items.forEach(item => {
                item.style.marginBottom = '0.5em';
                item.style.lineHeight = '1.5';
            });
        });
        
        return div.innerHTML;
    }

    
}