//
//  APIService.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import Alamofire
import ObjectMapper
import BrightFutures
import CleanroomLogger
import Result

extension Future {
    func recoverErrorWith(futureBuilder: Void -> Future<T, E>) -> Future<T, E> {
        return self.recoverWith { error in
            if let e = NetworkDataProvider.ErrorCodes.fromError(error as NSError) where e == .InvalidSessionError {
                api().sessionController.setAccessTokenResponse(AccessTokenResponse.invalidAccessToken())
            }
            
            if let e = NetworkDataProvider.ErrorCodes.fromError(error as NSError) where e == .ParsingError {
                return Future(error: error)
            }
            
            return futureBuilder()
        }
    }
}

final class APIService {
    init (
        url: NSURL,
        dataProvider: NetworkDataProvider = NetworkDataProvider(),
        sessionController: SessionController = SessionController()
        ) {
            baseURL = url
            self.dataProvider = dataProvider
            self.sessionController = sessionController
    }
    
    //MARK: - Error handling -
    
    typealias ErrorHandler = (NSError) -> ()
    
    var defaultErrorHandler: ErrorHandler?
    
    func handleFailure<R>(fb: Void -> Future<R, NSError>) -> Future<R, NSError> {
        return fb().recoverErrorWith(fb).recoverErrorWith(fb).recoverErrorWith(fb).onFailure { error in
            if let e = NetworkDataProvider.ErrorCodes.fromError(error) where e == .SessionRevokedError {
                self.logout()
            }
            self.defaultErrorHandler?(error)
            
            trackEventToAnalytics(AnalyticCategories.network, action: AnalyticActios.error, label: error.localizedDescription, value: NSNumber(integer: error.code))
        }
    }
    
    //MARK: - Variables -
    
    private let baseURL: NSURL
    //TODO: make private
    internal let dataProvider: NetworkDataProvider
    internal let sessionController: SessionController
    
    var description: String {
        return "API: \(baseURL.absoluteString)"
    }
    
    //pushes
    
    func setDeviceToken(deviceToken: String?) {
        sessionController.setDeviceToken(deviceToken)
    }
    
    func pushesRegistration() -> Future<Void, NSError> {
        let deviceToken = sessionController.currentDeviceToken()
        let endpoint = UserProfile.pushesEndpoint()
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        var params: [String: String]? = nil
        let device = UIDevice.currentDevice()
        if let dc = deviceToken,
        let uuid = device.identifierForVendor{
            params = ["registrationId": dc, "uuid" : uuid.UUIDString]
        }
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<Void, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.emptyResponseMapping(), validation: nil)
            return future
        }
    }
    
    //MARK: - Profile -
    
    func changePassword(oldPassword: String?, newPassword: String?) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        let endpoint = UserProfile.changePasswordEndpoint()
        var params: [String: String]? = nil
        if let oldPassword = oldPassword,
            let newPassword = newPassword {
                params = ["oldPassword" : oldPassword, "newPassword" : newPassword]
        }
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Void, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func getMyProfile() -> Future<UserProfile, NSError> {
        let endpoint = UserProfile.myProfileEndpoint()
        return getObject(endpoint)
    }
    
    func updateMyProfile(object: UserProfile) -> Future<Void, NSError> {
        let endpoint = UserProfile.myProfileEndpoint()
        return updateObject(endpoint, object: object)
    }
    
    func getUserProfile(userId: CRUDObjectId) -> Future<UserProfile, NSError> {
        let endpoint = UserProfile.userEndpoint(userId)
        return getObject(endpoint)
    }
    
    //MARK: - Wallet -
    
    func getDonations(userId: CRUDObjectId) -> Future<CollectionResponse<Order>, NSError> {
        let endpoint = "/v1.0/payments/users/\(userId)/donations"
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getOrders(userId: CRUDObjectId, reason: String) -> Future<CollectionResponse<Order>, NSError> {
        let endpoint = "/v1.0/payments/users/\(userId)/orders/\(reason)"
        return getObjectsCollection(endpoint, params: nil)
    }
    
    //MARK: - Posts -
    
    func getUserPosts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Post>, NSError> {
        let endpoint = Post.userPostsEndpoint(userId)
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func getPost(postId: CRUDObjectId) -> Future<Post, NSError> {
        let endpoint = Post.endpoint(postId)
        return getObject(endpoint)
    }
    
    func getPostComments(postId: CRUDObjectId) -> Future<CollectionResponse<Comment>, NSError> {
        let endpoint = "/v1.0/posts/\(postId)/comments"
        return getObjectsCollection(endpoint, params: nil)
    }
    
    
    func createUserPost(post object: Post) -> Future<Post, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Post, NSError> in
            let endpoint = Post.userPostsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityPost(post object: Post) -> Future<Post, NSError> {
        let endpoint = Post.communityPostsEndpoint()
        return createObject(endpoint, object: object)
    }
    
    func likePost(postId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Post.likeEndpoint(postId)
        return updateCommand(endpoint)
    }
    
    func unlikePost(postId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Post.likeEndpoint(postId)
        return updateCommand(endpoint, method: .DELETE)
    }
    
    func createPostComment(postId: CRUDObjectId, object: Comment) -> Future<Comment, NSError> {
        let endpoint = Post.postCommentEndpoint(postId)
        return createObject(endpoint, object: object)
    }
    
    //MARK: - Promotions -
    
    func getUserPromotions(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Promotion>, NSError> {
        let endpoint = Promotion.endpoint()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func createUserPromotion(object: Promotion) -> Future<Promotion, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Promotion, NSError> in
            let endpoint = Promotion.userPromotionsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityPromotion(communityId: CRUDObjectId, promotion object: Promotion) -> Future<Promotion, NSError> {
        let endpoint = Promotion.communityPromotionsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }

    func getPromotion(objectId: CRUDObjectId) -> Future<Promotion, NSError> {
        let endpoint = Promotion.endpoint(objectId)
        return getObject(endpoint)
    }
    
    //MARK: - Events -
    
    func getUserEvents(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Event>, NSError> {
        let endpoint = Event.userEventsEndpoint(userId)
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func createUserEvent(object: Event) -> Future<Event, NSError> {
        return currentUserId().flatMap {
            (userId: CRUDObjectId) -> Future<Event, NSError> in
            let endpoint = Event.userEventsEndpoint(userId)
            return self.createObject(endpoint, object: object)
        }
    }
    
    func createCommunityEvent(communityId: CRUDObjectId, event object: Event) -> Future<Event, NSError> {
        let endpoint = Event.communityEventsEndpoint(communityId)
        return createObject(endpoint, object: object)
    }

    func getEvent(objectId: CRUDObjectId) -> Future<Event, NSError> {
        let endpoint = Event.endpoint(objectId)
        return getObject(endpoint)
    }
    
    func attendEvent(objectId: CRUDObjectId, attend: Bool) -> Future<Void, NSError> {
        let method: Alamofire.Method = attend ? Method.POST : Method.DELETE
        let endpoint = Event.endpointAttend(objectId)
        return updateCommand(endpoint, method: method)
    }
    
    //MARK: - Products -
    
    func getUserProducts(userId: CRUDObjectId, page: Page) -> Future<CollectionResponse<Product>, NSError> {
        return self.getUserProfile(userId).flatMap { profile -> Future<CollectionResponse<Product>, NSError> in
            let endpoint = Product.shopItemsEndpoint(profile.defaultShopId)
            let params = page.query
            return self.getObjectsCollection(endpoint, params: params)
        }
    }

    func createProduct(object: Product, inShop shop: CRUDObjectId) -> Future<Product, NSError> {
        let endpoint = Product.shopItemsEndpoint(shop)
        return self.createObject(endpoint, object: object)
    }
    
    //MARK: - Membership -
    
    func getMemberships() -> Future<CollectionResponse<MembershipPlan>, NSError> {
        let endpoint = MembershipPlan.endpoint()
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getMembership(membershipId: CRUDObjectId) -> Future<MembershipPlan, NSError> {
        let endpoint = MembershipPlan.endpoint(membershipId)
        return getObject(endpoint)
    }
    
    //MARK: - Ambulance Membership -
    
    func getEPlusMemberships() -> Future<CollectionResponse<EPlusMembershipPlan>, NSError> {
        let endpoint = EPlusMembershipPlan.endpoint()
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getEPlusMembership(membershipId: CRUDObjectId) -> Future<EPlusMembershipPlan, NSError> {
        let endpoint = EPlusMembershipPlan.endpoint(membershipId)
        return getObject(endpoint)
    }
    
    func getEPlusServices() -> Future<CollectionResponse<EPlusService>, NSError> {
        var items = [EPlusService]()
        
        // Residential Estates
        var hourEvacuation = EPlusService()
        hourEvacuation.objectId = CRUDObjectId(0)
        hourEvacuation.name = "24 Hour Evacuation"
        hourEvacuation.shortDesc = "Available 24 hours a day"
        hourEvacuation.serviceDesc = "Emergency Plus Medical Services is dedicated to providing 24 hour emergency rescue services countrywide. Eplus has the largest capacity of ambulances which respond to medical emergencies of members and non members.\n\nA medical emergency is any life threatening injury or illness that if not treated immediately may lead to disability or death."
        hourEvacuation.footnote = "*A small fee will be charged to non-members depending on the distance"
        
        var hourEvacuationGroups = [InfoGroup]()
        var hourEvacuationEmergencies = [String]()
        hourEvacuationEmergencies.append("Breathing difficulty")
        hourEvacuationEmergencies.append("Chest pain")
        hourEvacuationEmergencies.append("Choking")
        hourEvacuationEmergencies.append("Fainting or loss of consciousness")
        hourEvacuationEmergencies.append("Bleeding that does not stop")
        hourEvacuationEmergencies.append("Coughing up or vomiting blood")
        hourEvacuationEmergencies.append("Severe or persistent vomiting")
        hourEvacuationEmergencies.append("Near drowning")
        hourEvacuationEmergencies.append("Burns")
        hourEvacuationEmergencies.append("Trauma due to motor vehicle accidents or falls")
        hourEvacuationEmergencies.append("Poisoning and drug overdose")
        hourEvacuationEmergencies.append("Sudden severe abdominal pain")
        hourEvacuationEmergencies.append("Stroke")
        hourEvacuationEmergencies.append("Convulsions without any history")
        hourEvacuationEmergencies.append("Obstetric emergencies")
        hourEvacuationEmergencies.append("Snake bites")
        hourEvacuationGroups.append(InfoGroup(title: "Some of the Medical emergencies are:", infoBlocks: hourEvacuationEmergencies))
        
        var hourEvacuationNumbers = [String]()
        hourEvacuationNumbers.append("1199")
        hourEvacuationNumbers.append("0700 395 395")
        hourEvacuationNumbers.append("0738 395 395")
        hourEvacuationNumbers.append("Landline +254-20-2655251")
        hourEvacuationGroups.append(InfoGroup(title: "Emergency numbers", infoBlocks: hourEvacuationNumbers))
        
        
        var hourEvacuationLinks = [TextLink(title: "1199", type: .PhoneNumber)]
        hourEvacuationLinks.append(TextLink(title: "0700 395 395", type: .PhoneNumber))
        hourEvacuationLinks.append(TextLink(title: "0738 395 395", type: .PhoneNumber))
        hourEvacuationLinks.append(TextLink(title: "+254-20-2655251", type: .PhoneNumber))
        hourEvacuation.textLinks = hourEvacuationLinks
        
        var hourEvacuationTypesOfAmbulance = [String]()
        hourEvacuationTypesOfAmbulance.append("Basic Life Support ambulances (BLS) and Advanced Cardiac Life Support ambulances (ACLS)")
        hourEvacuationTypesOfAmbulance.append("We have Landcruiser and Toyota Hiace High Roof ambulances")
        hourEvacuationTypesOfAmbulance.append("The ambulances are tropicalized for the country, are fully air conditioned and are fitted with DC/AC inverters")
        hourEvacuationGroups.append(InfoGroup(title: "Types of ambulance", infoBlocks: hourEvacuationTypesOfAmbulance))
        
        var hourEvacuationMedicalPersonnel = [String]()
        hourEvacuationMedicalPersonnel.append("ICU/A&E nurses that are trained in Pre-Hospital Care")
        hourEvacuationMedicalPersonnel.append("Emergency Medical Technicians that have specialized in trauma and EVOC")
        hourEvacuationMedicalPersonnel.append("Highly skilled and capable in handling all medical emergencies")
        hourEvacuationGroups.append(InfoGroup(title: "Medical personnel", infoBlocks: hourEvacuationMedicalPersonnel))
        
        var hourEvacuationHowToCall = [String]()
        hourEvacuationHowToCall.append("State your name and telephone number")
        hourEvacuationHowToCall.append("Your location")
        hourEvacuationHowToCall.append("Nature of the emergency")
        hourEvacuationHowToCall.append("Number of casualties")
        hourEvacuationHowToCall.append("Whether you are a member or not")
        hourEvacuationGroups.append(InfoGroup(title: "How to call for an ambulance", infoBlocks: hourEvacuationHowToCall))
        
        hourEvacuation.infoBlocks = hourEvacuationGroups
        
        items.append(hourEvacuation)
        

        
        var evacuation = EPlusService()
        evacuation.objectId = CRUDObjectId(1)
        evacuation.name = "Cross Border Evacuation"
        evacuation.shortDesc = "Available on request"
        evacuation.serviceDesc = "These are evacuations or transfers that we do from one country to another within the greater east African community for stable patients that have been discharged from the hospital or those that have terminal illnesses."
        evacuation.footnote = "*The cross border transfer charges depend on the distance and related costs"
        
        var evacuationGroups = [InfoGroup]()
        var evacuationDeployment = [String]()
        evacuationDeployment.append("We deploy appropriate fully equipped ambulances, personnel and supplies.")
        evacuationGroups.append(InfoGroup(title: "Deployment", infoBlocks: evacuationDeployment))
        
        var evacuationPatientPreparation = [String]()
        evacuationPatientPreparation.append("The patient must have a medical report, travel documents, appropriate vaccinations and a relative to accompany.")
        evacuationGroups.append(InfoGroup(title: "Patient preparation", infoBlocks: evacuationPatientPreparation))
        
        var evacuationBookAnAmbulance = [String]()
        evacuationBookAnAmbulance.append("Send an email with the details below to dispatch@eplus.co.ke")
        evacuationBookAnAmbulance.append("Your name and town of residence")
        evacuationBookAnAmbulance.append("Patient location and direction")
        evacuationBookAnAmbulance.append("State if patient is a stretcher case, on a wheelchair, sitting or walking")
        evacuationBookAnAmbulance.append("Admitting hospital, town and country")
        evacuationBookAnAmbulance.append("Whether medical report, VISA and vaccination have been done")
        evacuationBookAnAmbulance.append("Date and time of the intended ambulance transfer")
        evacuationBookAnAmbulance.append("Name of person accompanying and relationship, if available")
        evacuationGroups.append(InfoGroup(title: "How to book an ambulance", infoBlocks: evacuationBookAnAmbulance))
        
        evacuation.infoBlocks = evacuationGroups
        evacuation.textLinks = [TextLink(title: "dispatch@eplus.co.ke", type: .Email)]
        items.append(evacuation)
        
    
        
        
        
        var eventCoverage = EPlusService()
        eventCoverage.objectId = CRUDObjectId(2)
        eventCoverage.name = "Standby ambulance service for events"
        eventCoverage.shortDesc = "Corporate, school, sports, liveshows"
        eventCoverage.serviceDesc = "Via this service, we provide appropriate standby ambulances and personnel for sporting events, safari rally, meetings, launches with large crowds, funeral gatherings and parties etc."
        eventCoverage.footnote = "A small fee will be charged to non-members depending on the distance"
        
        var eventCoverageGroups = [InfoGroup]()
        var eventCoverageOurCharges = [String]()
        eventCoverageOurCharges.append("Our subsidized rates depend on the duration, distance and personnel required.")
        eventCoverageGroups.append(InfoGroup(title: "Our charges", infoBlocks: eventCoverageOurCharges))
        
        var eventRequestTheService = [String]()
        eventRequestTheService.append("Send to us the details of the event one week prior to the event, send us its details including date, start and end time, nature of the event, location, number of participants, telephone contacts, postal address and person/organisation paying for the event.\n\nAlternatively, you can fill in the event request form below and send to dispatch@eplus.co.ke")
        eventCoverageGroups.append(InfoGroup(title: "How to request the service ", infoBlocks: eventRequestTheService))
        eventCoverage.textLinks = [TextLink(title: "dispatch@eplus.co.ke", type: .Email)]
        
        var eventConfirmation = [String]()
        eventConfirmation.append("We will send you a quotation within the same day and wait for payment. Confirmation will be done once payment has been made.")
        eventCoverageGroups.append(InfoGroup(title: "Confirmation", infoBlocks: eventConfirmation))
    
        var eventreport = [String]()
        eventreport.append("This will be made available to you once you sign off for the ambulance at the end of the event and within 48 hours.")
        eventCoverageGroups.append(InfoGroup(title: "Event report", infoBlocks: eventreport))
        
        var eventHowToCallAmbulance = [String]()
        eventHowToCallAmbulance.append("State your name and telephone number")
        eventHowToCallAmbulance.append("Your location")
        eventHowToCallAmbulance.append("Nature of the emergency")
        eventHowToCallAmbulance.append("Number of casualties")
        eventHowToCallAmbulance.append("Whether you are a member or not")
        eventCoverageGroups.append(InfoGroup(title: "How to call for an ambulance", infoBlocks: eventHowToCallAmbulance))
        
        eventCoverage.infoBlocks = eventCoverageGroups
        
        items.append(eventCoverage)
        
        return Future(value: CollectionResponse(items:items, total: items.count), delay: 0.5)
    }
    
    func getEPlusActiveMembership() -> Future<EplusMembershipDetails, NSError> {
        let endpoint = EplusMembershipDetails.endpoint()
        return getObject(endpoint)
    }
    
    func createEPlusOrder(planOptions object: EPlusPlanOptions) -> Future<EplusMembershipDetails, NSError> {
        let endpoint = EPlusPlanOptions.endpoint()
        
        let responseMapping: AnyObject? -> EplusMembershipDetails? = { response in
            if let json = response as? NSDictionary {
                return Mapper<EplusMembershipDetails>().map(json)
            }
            return nil
        }
        
        typealias CRUDResultType = (Alamofire.Request, Future<EplusMembershipDetails, NSError>)
        
        let futureBuilder: (Void -> Future<EplusMembershipDetails, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<EplusMembershipDetails, NSError> in
                let params = Mapper().toJSON(object)
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                
                let (_ , future): CRUDResultType = self.dataProvider.jsonRequest(request, map: responseMapping, validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    //MARK: - Community -
    
    func getCommunities(page: Page) -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = Community.endpointCommunities()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }

    func getUserVolunteers(userId: CRUDObjectId) -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = Volunteer.userVolunteersEndpoint(userId)
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getUserCommunities(userId: CRUDObjectId) -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = Community.userCommunitiesEndpoint(userId)
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getCommunity(communityId: CRUDObjectId) -> Future<Community, NSError> {
        let endpoint = Community.communityEndpoint(communityId)
        return getObject(endpoint)
    }
    
    func createCommunity(community object: Community) -> Future<Community, NSError> {
        let endpoint = Community.endpoint()
        return createObject(endpoint, object: object)
    }
    
    func updateCommunity(community object: Community) -> Future<Void, NSError> {
        let endpoint = Community.communityEndpoint(object.objectId)
        return updateObject(endpoint, object: object)
    }
    
    func joinCommunity(communityId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = Community.membersEndpoint(communityId)
        return updateCommand(endpoint)
    }
    
    func leaveCommunity(communityId: CRUDObjectId) -> Future<Void, NSError> {
        //TODO: hardcode, change on server endpoint update
        let endpoint = "/v1.0/community/\(communityId)/members"
        return updateCommand(endpoint, method:.DELETE)
    }
    
    //MARK: - Ambulance - 
    
    func createAmbulanceRequest(object: AmbulanceRequest) -> Future<AmbulanceRequest, NSError> {
        let endpoint = AmbulanceRequest.endpoint()
        typealias CRUDResultType = (Alamofire.Request, Future<AmbulanceRequest, NSError>)
        let params = Mapper().toJSON(object)
        
        let futureBuilder: (Void -> Future<AmbulanceRequest, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<AmbulanceRequest, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return handleFailure(futureBuilder)
    }
    
    func deleteAmbulanceRequest(objectId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = AmbulanceRequest.endpoint(objectId)
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Void, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .DELETE)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.emptyResponseMapping(), validation: nil)
                return future
            }
        }
        
        return handleFailure(futureBuilder)
    }
    
    //MARK: - People -
    
    func getUsers(page: Page) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.endpoint()
        let params = page.query
        return getObjectsCollection(endpoint, params: params)
    }
    
    func getUsers(userIds: [CRUDObjectId]) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.endpoint()
        let params = APIServiceQuery()
        params.append("ids", value: userIds)
        
        //TODO: refactor, use generics
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<UserInfo>, NSError>)        
        
        let futureBuilder: (Void -> Future<CollectionResponse<UserInfo>, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<CollectionResponse<UserInfo>, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
                let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return handleFailure(futureBuilder)
    }
    
    func getMySubscriptions() -> Future<CollectionResponse<UserInfo>,NSError> {
        return currentUserId().flatMap { userId in
            return self.getUserSubscriptions(userId)
        }
    }
    
    func getUserSubscriptions(userId: CRUDObjectId) -> Future<CollectionResponse<UserInfo>,NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func getSubscriptionStateForUser(userId: CRUDObjectId) -> Future<UserProfile.SubscriptionState, NSError> {
        //TODO: use follow":true from user profile response
        if isCurrentUser(userId) {
            return Future(value: .SameUser)
        }
        return getMySubscriptions().map { (response: CollectionResponse<UserInfo>) -> UserProfile.SubscriptionState in
            if (response.items.filter { $0.objectId == userId }).count > 0 {
                return .Following
            } else {
                return .NotFollowing
            }
        }
    }
    
    func followUser(userId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return updateCommand(endpoint)
    }

    func unFollowUser(userId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = UserProfile.subscripttionEndpoint(userId)
        return updateCommand(endpoint, method: .DELETE)
    }

    //MARK: - Feed items -
    
    func likeFeedItem(feedItem: FeedItem) -> Future<Void, NSError> {
        let endpoint = feedItem.likeEndpoint()
        return updateCommand(endpoint)
    }
    
    func unlikeFeedItem(feedItem: FeedItem) -> Future<Void, NSError> {
        let endpoint = feedItem.likeEndpoint()
        return updateCommand(endpoint, method: .DELETE)
    }
    
    //MARK: - Search -
    
    func getSearchFeed(query: APIServiceQueryConvertible, page: Page) -> Future<QuickSearchResponse,NSError> {
        let endpoint = SearchItem.endpoint()
        let params = APIServiceQuery()
        params.append(query: query)
        params.append(query: page)
        Log.debug?.value(params.query)
        
        let futureBuilder: (Void -> Future<QuickSearchResponse, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<QuickSearchResponse, NSError> in
                
                let request = self.updateRequest(token, endpoint: endpoint, params: params.query)
                let (_ , future): (Alamofire.Request, Future<QuickSearchResponse, NSError>) = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func getFeed(query: APIServiceQueryConvertible, page: Page) -> Future<CollectionResponse<FeedItem>,NSError> {
        let endpoint = FeedItem.endpoint()
        let params = APIServiceQuery()
        params.append(query: query)
        params.append(query: page)
        //TODO: should refactor
        params.append("type", value: "2,8")

        return self.getObjectsCollection(endpoint, params: params.query)
    }
    
    func getAll(homeItem: HomeItem, seachFilter: SearchFilter) -> Future<CollectionResponse<FeedItem>,NSError> {
        let endpoint = homeItem.endpoint()
        //TODO: should refactor
        let params = APIServiceQuery()
        params.append("type", value: String(homeItem.rawValue))
        if let itemTypes = seachFilter.itemTypes {
            var itemTypesArray : [String] = []
            
            for (_, value) in itemTypes.enumerate() {
                itemTypesArray.append(String(value.rawValue))
            }
            params.append("type", value: itemTypesArray)
        }
        
        if let communities = seachFilter.communities {
            params.append("communities", value: communities)
        }
        
        var parameters = [String:AnyObject]()
        for (key, value) in params.query {
            if let array = value as? [String] {
                parameters[key] = array.joinWithSeparator(",")
            } else {
                parameters[key] = value
            }
        }
        
        return self.getObjectsCollection(endpoint, params: parameters)
    }
    
    func getVolunteers() -> Future<CollectionResponse<Community>,NSError> {
        let endpoint = HomeItem.Volunteer.endpoint()
        let method: Alamofire.Method = .GET
        
        let futureBuilder: (Void -> Future<CollectionResponse<Community>, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<CollectionResponse<Community>, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: method)
                let (_ , future): (Alamofire.Request, Future<CollectionResponse<Community>, NSError>) = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func getCountyBranches(page: Page) -> Future<CollectionResponse<Community>, NSError> {
        let endpoint = HomeItem.Volunteer.endpoint()
        var params = page.query
        params["filterByParticipationStatus"] = false
        return getObjectsCollection(endpoint, params: params)
    }

    func getVolunteer(volunteerId: CRUDObjectId) -> Future<Community, NSError> {
        let endpoint = Volunteer.volunteerEndpoint(volunteerId)
        return getObject(endpoint)
    }
    
    func joinVolunteer(volunteerId: CRUDObjectId) -> Future<Void, NSError> {
        let endpoint = "/v1.0/volunteer/\(volunteerId)/members"
        return updateCommand(endpoint)
    }
    
    func leaveVolunteer(volunteerId: CRUDObjectId) -> Future<Void, NSError> {
        //TODO: hardcode, change on server endpoint update
        let endpoint = "/v1.0/volunteer/\(volunteerId)/members"
        return updateCommand(endpoint, method:.DELETE)
    }
    
    func getBomaHotelsDetails(objectId: CRUDObjectId) -> Future<BomaHotel, NSError> {
        let endpoint = HomeItem.BomaHotels.endpoint(objectId)
        //TODO need fix downcastng
        
        let futureBuilder: (Void -> Future<BomaHotel, NSError>) = { [unowned self] in
            self.session().flatMap {
                (token: AuthResponse.Token) -> Future<BomaHotel, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint!, params: nil, method: .GET)
                let (_ , future): (Alamofire.Request, Future<BomaHotel, NSError>) = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func getProjectsDetails(objectId: CRUDObjectId) -> Future<Product, NSError> {
        let endpont = HomeItem.Projects.endpoint(objectId)
        //TODO need fix downcastng
        return self.getOne(endpont!)
    }
    
    func getGiveBloodDetails(objectId: CRUDObjectId) -> Future<Product, NSError> {
        let endpont = HomeItem.GiveBlood.endpoint(objectId)
        return self.getOne(endpont!)
    }
    
    func getEmergencyDetails(objectId: CRUDObjectId) -> Future<Product, NSError> {
        let endpont = HomeItem.Emergency.endpoint(objectId)
        return self.getOne(endpont!)
    }
    
    func getMarketDetails(objectId: CRUDObjectId) -> Future<Product, NSError> {
        let endpont = HomeItem.Market.endpoint(objectId)
        return self.getOne(endpont!)
    }
    
    func getTrainingDetails(objectId: CRUDObjectId) -> Future<Product, NSError> {
        let endpont = HomeItem.Training.endpoint(objectId)
        return self.getOne(endpont!)
    }
    
    private func getOne(endpoint: String) -> Future<Product, NSError> {
        let futureBuilder: (Void -> Future<Product, NSError>) = { [unowned self] in
            self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Product, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, params: nil, method: .GET)
                let (_ , future): (Alamofire.Request, Future<Product, NSError>) = self.dataProvider.objectRequest(request)
                return future
            }
        }
    
        return self.handleFailure(futureBuilder)
    }

    //MARK: - Notifications

    func getNotifications() -> Future<CollectionResponse<SystemNotification>, NSError> {
        let endpoint = SystemNotification.endpoint()
        return getObjectsCollection(endpoint, params: nil)
    }
    
    func readNotifications(notificationsIds: [String]) -> Future<Void, NSError> {
        let endpoint = SystemNotification.endpoint()
        
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Void, NSError> in
                let params = ["notificationIds": notificationsIds]
                let request = self.updateRequest(token, endpoint: endpoint, method: .PUT, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func hasNotifications() -> Future<Bool, NSError> {
        let endpoint = SystemNotification.endpoint()
        let page = Page(start: 0, size: 1)
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<SystemNotification>, NSError>)
        
        let futureBuilder: (Void -> Future<CollectionResponse<SystemNotification>, NSError>) = { [unowned self] in
            self.session().flatMap {
                (token: AuthResponse.Token) -> Future<CollectionResponse<SystemNotification>, NSError> in
                let request = self.readRequest(token, endpoint: endpoint, params: page.query)
                let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return futureBuilder().flatMap{ (response : CollectionResponse<SystemNotification>) -> Future<Bool, NSError> in
                let result = response.items.count > 0 ? true : false
                return Future(value: result)
        }
    }
    
    //MARK: - MPesa requests
    
    func transactionStatusMpesa(transactionId: String) -> Future<String, NSError> {
        let endpoint = MPesaPayment.productCheckoutEndpoint(itemId: transactionId)
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<String, NSError> in
            let request = self.updateRequest(token, endpoint: endpoint, method: .GET, params: nil)
            let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.checkoutMapping(), validation: nil)
            return future
        }
    }

    func productCheckoutMpesa(amount:NSNumber, nonce:String, itemId: String, quantity: NSNumber) -> Future<String, NSError> {
        let endpoint = MPesaPayment.productCheckoutEndpoint()
        let  params = ["payment_method_nonce": nonce, "amount" : amount, "itemId" : itemId, "quantity": quantity]
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.mpesaMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func membershipCheckoutMpesa(amount:String, nonce:String, membershipId: String) -> Future<String, NSError> {
        let endpoint = MPesaPayment.membershipCheckoutEndpoint()
        let params = ["payment_method_nonce": nonce, "amount" : amount, "itemId" : membershipId]
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.mpesaMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func donateCheckoutMpesa(amount:String, nonce:String) -> Future<String, NSError> {
        let endpoint = MPesaPayment.donateCheckoutEndpoint()
        let params = ["payment_method_nonce": nonce, "amount" : amount]
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.mpesaMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    //MARK: - Braintree requests

    func getToken() -> Future<String, NSError> {
        let endpoint = BraintreePayment.tokenEndpoint()
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.readRequest(token, endpoint: endpoint)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.tokenMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func productCheckoutBraintree(amount:String, nonce:String, itemId: String, quantity: NSNumber) -> Future<String, NSError> {
        let endpoint = BraintreePayment.productCheckoutEndpoint()
        let  params = ["payment_method_nonce": nonce, "amount" : amount, "itemId" : itemId, "quantity": quantity]
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.checkoutMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    func membershipCheckoutBraintree(amount:String, nonce:String, membershipId: String) -> Future<String, NSError> {
        let endpoint = BraintreePayment.membershipCheckoutEndpoint()
        let  params = ["payment_method_nonce": nonce, "amount" : amount, "itemId" : membershipId]
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)
        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.checkoutMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }

    func donateCheckoutBraintree(amount:String, nonce:String, itemId:String?) -> Future<String, NSError> {
        let endpoint = BraintreePayment.donateCheckoutEndpoint()
        var params = ["payment_method_nonce": nonce, "amount" : amount]
        if let itemId = itemId {
            params = ["payment_method_nonce": nonce, "amount" : amount, "itemId" : itemId]
        }
        typealias CRUDResultType = (Alamofire.Request, Future<String, NSError>)

        
        let futureBuilder: (Void -> Future<String, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<String, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: BraintreePayment.checkoutMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }

    //MARK: - Generic requests -
    
    private func getObjectsCollection<C: CRUDObject>(endpoint: String, params: [String : AnyObject]?) -> Future<CollectionResponse<C>, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<CollectionResponse<C>, NSError>)
        
        let futureBuilder: (Void -> Future<CollectionResponse<C>, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<CollectionResponse<C>, NSError> in
                let request = self.readRequest(token, endpoint: endpoint, params: params)
                let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    private func getObject<C: CRUDObject>(endpoint: String) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<C, NSError>)
        
        let futureBuilder: (Void -> Future<C, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<C, NSError> in
                let request = self.readRequest(token, endpoint: endpoint)
                let (_, future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    private func createObject<C: CRUDObject>(endpoint: String, object: C) -> Future<C, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<UpdateResponse, NSError>)
        
        let futureBuilder: (Void -> Future<C, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<C, NSError> in
                let params = Mapper().toJSON(object)
                let request = self.updateRequest(token, endpoint: endpoint, method: .POST, params: params)
                let (_ , future): CRUDResultType = self.dataProvider.objectRequest(request)
                return future.map { (updateResponse: UpdateResponse) -> C in
                    var updatedObject = object
                    updatedObject.objectId = updateResponse.objectId
                    return updatedObject
                }
            }
        }
        
        return self.handleFailure(futureBuilder)
    }

    
    private func updateCommand(endpoint: String, method: Alamofire.Method = .POST) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Void, NSError> in
                let request = self.updateRequest(token, endpoint: endpoint, method: method, params: nil)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.commandMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }

    
    private func updateObject<C: CRUDObject>(endpoint: String, object: C) -> Future<Void, NSError> {
        typealias CRUDResultType = (Alamofire.Request, Future<Void, NSError>)
        
        let futureBuilder: (Void -> Future<Void, NSError>) = { [unowned self] in
            return self.session().flatMap {
                (token: AuthResponse.Token) -> Future<Void, NSError> in
                let params = Mapper().toJSON(object)
                let request = self.updateRequest(token, endpoint: endpoint, method: .PUT, params: params)
                let (_, future): CRUDResultType = self.dataProvider.jsonRequest(request, map: self.emptyResponseMapping(), validation: nil)
                return future
            }
        }
        
        return self.handleFailure(futureBuilder)
    }
    
    //MARK: - Helpers -
    
//TODO:    @availability(*, unavailable)
    
    private func emptyResponseMapping() -> (AnyObject? -> Void?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let errorMessage = json["message"] as? String {
                    Log.error?.message("Server Error: \(errorMessage)")
                } else {
                    Log.error?.message("Got unexpected answer")
                    Log.debug?.value(json)
                }
                return nil
            }
            return ()
        }
    }
    
    func commandMapping() -> (AnyObject? -> Void?) {
        return  { response in
            if let json = response as? NSDictionary {
                if let success = json["success"] as? Bool where success == true{
                        return ()
                } else {
                    Log.error?.message("Got unexpected response")
                    Log.debug?.value(json)
                    return nil
                }
            }
            //TODO: need handle nil response
            else if response == nil {
                return ()
            }

            else {
                Log.error?.message("Got unexpected response: \(response)")
                return nil
            }
        }
    }
    
    func statusCodeValidation<S: SequenceType where S.Generator.Element == Int>(statusCode acceptableStatusCode: S) -> Alamofire.Request.Validation {
        return { _, response in
            if acceptableStatusCode.contains(response.statusCode) {
                return .Success
            } else {                
                return .Failure(NetworkDataProvider.ErrorCodes.TransferError.error())
            }
        }
    }
    
    //TODO: make private, move to request
    internal func http(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "http")
    }
    //TODO: make private, move to request
    internal func https(endpoint: String) -> NSURL {
        return url(endpoint, scheme: "https")
    }

    //TODO: move to request
    private func url(endpoint: String, scheme: String, port: Int? = nil) -> NSURL {
        if let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) {
            components.scheme = scheme
            components.path = ((components.path ?? "") as NSString).stringByAppendingPathComponent(endpoint)
            if let port = port {
                components.port = port
            }
            if let url = components.URL {
                return url
            }
        }
        fatalError("Could not generate  url")
    }
    
    
    private func readRequest(token: String, endpoint: String, params: [String : AnyObject]? = nil) -> CRUDRequest {
        let request = CRUDRequest(token: token, url: https(endpoint))
        request.params = params
        return request
    }

    private func updateRequest(token: String, endpoint: String, method: Alamofire.Method = .POST, params: [String : AnyObject]? = nil) -> CRUDRequest {
        let request = CRUDRequest(token: token, url: https(endpoint))
        request.encoding = .JSON
        request.method = method
        request.params = params
        return request
    }
    
}

//MARK: - CRUD request -
extension APIService {
    
    private final class CRUDRequest: Alamofire.URLRequestConvertible {
        
        let token: String
        let url: NSURL
        
        var additionalHeaders: [String : String]?
        var method: Alamofire.Method = .GET
        var params: [String : AnyObject]?
        var encoding: Alamofire.ParameterEncoding = .URL
        
        init(token: String, url: NSURL) {
            self.token = token
            self.url = url
        }
        
        var URLRequest: NSMutableURLRequest {
            let r = NSMutableURLRequest(URL: url)
            r.HTTPMethod = method.rawValue
            var headers = [
                "Authorization": "Bearer \(token)",
                "Accept" : "application/json",
                "Connection": "close",
            ]
            if let additionalHeaders = additionalHeaders {
                for (key,value) in additionalHeaders {
                    headers.updateValue(value, forKey:key)
                }
            }
            r.allHTTPHeaderFields = headers
            return encoding.encode(r, parameters: params).0
        }
    }
}

//MARK: - Query -

protocol APIServiceQueryConvertible {
    var query: [String : AnyObject]  { get }
}

extension APIService {
    
    final class APIServiceQuery: APIServiceQueryConvertible {
        private var values: [String : AnyObject] = [:]

        func append(query newItems:APIServiceQueryConvertible) {
            for (key,value) in newItems.query {
                values.updateValue(value, forKey:key)
            }
        }
        
        func append(key: String, value: AnyObject) {
            values.updateValue(value, forKey:key)
        }
        
        var query: [String : AnyObject]  {
            return values
        }
    }
}

extension APIService {
    
    struct Page: APIServiceQueryConvertible {
        let skip: Int
        let take: Int
        init(start: Int = 0, size: Int = 100) {
            skip = start
            take = size
        }
        
        func next() -> Page {
            return Page(size: take, start: skip + take)
        }
        
        var query: [String : AnyObject]  {
            return [
                "skip" : skip,
                "take" : take,
            ]
        }
    }
}

//MARK: - Images -

extension APIService {
    
    func uploadImage(data: NSData, dataUTI: String) -> Future<NSURL, NSError> {
        let fileInfo = NetworkDataProvider.FileUpload(data: data, dataUTI: dataUTI)
        return session().flatMap {
            (token: AuthResponse.Token) -> Future<AnyObject?,NSError> in
            let urlRequest = self.imageRequest(token)
            return self.dataProvider.upload(urlRequest, files: [fileInfo])
            }.flatMap { (response: AnyObject?) -> Future<NSURL, NSError> in
                let f: Future<NSURL, NSError> = future {
                    guard let JSON = response as? [String: AnyObject],
                          let url = ImageURLTransform().transformFromJSON(JSON["url"])  else {
                            return Result(error: NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
                    }
                    return Result(value: url)
                }
                return f
        }
    }
    
    private func imageRequest(token: String) -> CRUDRequest {
        let url = https("/v1.0/photos/upload")
        let request = CRUDRequest(token: token, url: url)
        request.method = .POST
        return request
    }

}
