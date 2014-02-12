//
//  SQTLShipItWatcherSpec.m
//  Squirrel
//
//  Created by Keith Duncan on 15/01/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "SQRLShipItRequest.h"
#import "SQRLDirectoryManager.h"

SpecBegin(SQRLShipItWatcher)

it(@"should write a response when the target exits", ^{
	NSRunningApplication *testApplication = [self launchTestApplicationWithEnvironment:nil];

	SQRLShipItRequest *state = [[SQRLShipItRequest alloc] initWithUpdateBundleURL:[self createTestApplicationUpdate] targetBundleURL:testApplication.bundleURL bundleIdentifier:testApplication.bundleIdentifier launchAfterInstallation:NO];
	RACSignal *stateLocation = self.shipItDirectoryManager.shipItStateURL;
	expect([[state writeToURL:stateLocation.first] waitUntilCompleted:NULL]).to.beTruthy();

	NSString *requestPath = [stateLocation.first path];
	NSString *responsePath = [self.temporaryDirectoryURL URLByAppendingPathComponent:@"completed"].path;

	NSBundle *squirrelBundle = [NSBundle bundleWithIdentifier:@"com.github.Squirrel"];
	NSString *watcherExecutablePath = [squirrelBundle URLForResource:@"shipit-watcher" withExtension:nil].path;

	NSTask *watcherTask = [[NSTask alloc] init];
	watcherTask.launchPath = watcherExecutablePath;
	watcherTask.arguments = @[
		requestPath,
		responsePath,
	];

	[watcherTask launch];

	[NSThread sleepForTimeInterval:1];

	expect([NSFileManager.defaultManager fileExistsAtPath:responsePath]).notTo.beTruthy();

	[testApplication terminate];

	expect([NSFileManager.defaultManager fileExistsAtPath:responsePath]).will.beTruthy();
});

SpecEnd