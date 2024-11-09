import { LightningElement, track } from 'lwc';
import getArticleByTitle from '@salesforce/apex/KnowledgeArticleController.getArticleByTitle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KnowledgeBaseContainer extends LightningElement {
    @track selectedArticleContent = '';
    @track selectedArticleTitle = '';
    @track isMenuVisible = true;
    @track isUsersAndRoles = false;

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
            directorConfiguration: 'Director configuration',
            directorConfigurationsProperties: 'Director configurations: Properties',
            tasks: 'Director configurations: Tasks',
            users: 'Director configurations: Users',
            rolesPermissions: 'Director configurations: Roles/Permissions',
            groupsDepartments: 'Director configurations: Departments',
            loadBalancing: 'Director configurations: Load Balance',
            // BotManager submenu items
            botmanagerOverview: 'BotManager: Overview',
            botmanagerInstallation: 'BotManager: Installation and Initial Configuration',
            botmanagerManaging: 'BotManager: Customization in Config File',
            botmanagerWorking: 'BotManager: Bots and rDesktop',
            botmanagerMaintenance: 'BotManager: Maintenance, Troubleshooting, and Best Practices',
            dashboardManagementTools:'BotManager: Dashboard and Management Tools',
            // Other mappings
            profileAndResource: 'Profile Menu',
            directorLogs: 'Director Logs',
            botmanager: 'BotManager',
            events: 'Events and Notifications',
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

    // Fetch the article content
    fetchArticleContent(articleTitle) {
        console.log('Fetching article with title:', articleTitle);

        getArticleByTitle({ title: articleTitle })
            .then(result => {
                console.log('Fetched article:', result);

                if (!result) {
                    throw new Error('No article data returned');
                }

                // Access the fields directly from Knowledge__kav
                const articleContent = result.Content__c || result.Article_Body__c || result.Summary;

                if (!articleContent) {
                    this.selectedArticleContent = 'This article exists but has no content. Please contact your administrator.';
                    this.showToast('Warning', 'Article found but contains no content', 'warning');
                    return;
                }

                const cleanContent = this.cleanHTML(articleContent);
                this.selectedArticleContent = cleanContent;
                this.selectedArticleTitle = result.Title;

                // Log the content for debugging
                console.log('Article content:', articleContent);
            })
            .catch(error => {
                console.error('Error fetching article:', error);
                const errorMessage = error.body?.message || error.message || 'Unknown error occurred';
                this.selectedArticleContent = `Unable to load content: ${errorMessage}`;
                this.showToast('Error', errorMessage, 'error');
            });
    }

    // Function to clean up the HTML
    cleanHTML(content) {
        const div = document.createElement('div');
        div.innerHTML = content;
        // Remove any unwanted elements, e.g., background overlays
        div.querySelectorAll('div.background-image-overlay').forEach(node => node.remove());
        return div.innerHTML;
    }

    // Show a toast notification
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
