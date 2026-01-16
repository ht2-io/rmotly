BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "actions" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "httpMethod" text NOT NULL,
    "urlTemplate" text NOT NULL,
    "headersTemplate" text,
    "bodyTemplate" text,
    "openApiSpecUrl" text,
    "openApiOperationId" text,
    "parameters" text,
    "encryptedCredentials" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "action_user_idx" ON "actions" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "controls" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "name" text NOT NULL,
    "controlType" text NOT NULL,
    "actionId" bigint,
    "config" text NOT NULL,
    "position" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "control_user_idx" ON "controls" USING btree ("userId");
CREATE INDEX "control_position_idx" ON "controls" USING btree ("position");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "events" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "sourceType" text NOT NULL,
    "sourceId" text NOT NULL,
    "eventType" text NOT NULL,
    "payload" text,
    "actionResult" text,
    "timestamp" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "event_user_idx" ON "events" USING btree ("userId");
CREATE INDEX "event_timestamp_idx" ON "events" USING btree ("timestamp");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "notification_queue" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "subscriptionId" bigint,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "payload" text,
    "priority" text NOT NULL,
    "status" text NOT NULL,
    "deliveryTier" text,
    "attemptCount" bigint NOT NULL,
    "maxAttempts" bigint NOT NULL,
    "lastError" text,
    "createdAt" timestamp without time zone NOT NULL,
    "scheduledAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "deliveredAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "queue_user_idx" ON "notification_queue" USING btree ("userId");
CREATE INDEX "queue_status_idx" ON "notification_queue" USING btree ("status", "scheduledAt");
CREATE INDEX "queue_subscription_idx" ON "notification_queue" USING btree ("subscriptionId");
CREATE INDEX "queue_expires_idx" ON "notification_queue" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "notification_topics" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "apiKey" text NOT NULL,
    "enabled" boolean NOT NULL,
    "config" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "topic_user_idx" ON "notification_topics" USING btree ("userId");
CREATE UNIQUE INDEX "topic_api_key_idx" ON "notification_topics" USING btree ("apiKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "push_subscriptions" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "p256dh" text,
    "auth" text,
    "subscriptionType" text NOT NULL,
    "deviceId" text NOT NULL,
    "userAgent" text,
    "active" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "lastUsedAt" timestamp without time zone,
    "failureCount" bigint NOT NULL
);

-- Indexes
CREATE INDEX "subscription_user_idx" ON "push_subscriptions" USING btree ("userId");
CREATE UNIQUE INDEX "subscription_endpoint_idx" ON "push_subscriptions" USING btree ("endpoint");
CREATE UNIQUE INDEX "subscription_device_idx" ON "push_subscriptions" USING btree ("userId", "deviceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "displayName" text,
    "fcmToken" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_email_idx" ON "users" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_key" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "hash" text NOT NULL,
    "scopeNames" json NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_auth_key_userId_idx" ON "serverpod_auth_key" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_email_auth" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_email" ON "serverpod_email_auth" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_email_create_request" (
    "id" bigserial PRIMARY KEY,
    "userName" text NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL,
    "verificationCode" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_create_account_request_idx" ON "serverpod_email_create_request" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_email_failed_sign_in" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "ipAddress" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_email_failed_sign_in_email_idx" ON "serverpod_email_failed_sign_in" USING btree ("email");
CREATE INDEX "serverpod_email_failed_sign_in_time_idx" ON "serverpod_email_failed_sign_in" USING btree ("time");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_email_reset" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "verificationCode" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_reset_verification_idx" ON "serverpod_email_reset" USING btree ("verificationCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_google_refresh_token" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "refreshToken" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_google_refresh_token_userId_idx" ON "serverpod_google_refresh_token" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_user_image" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "version" bigint NOT NULL,
    "url" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_user_image_user_id" ON "serverpod_user_image" USING btree ("userId", "version");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_user_info" (
    "id" bigserial PRIMARY KEY,
    "userIdentifier" text NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "created" timestamp without time zone NOT NULL,
    "imageUrl" text,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_user_info_user_identifier" ON "serverpod_user_info" USING btree ("userIdentifier");
CREATE INDEX "serverpod_user_info_email" ON "serverpod_user_info" USING btree ("email");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "actions"
    ADD CONSTRAINT "actions_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "controls"
    ADD CONSTRAINT "controls_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "controls"
    ADD CONSTRAINT "controls_fk_1"
    FOREIGN KEY("actionId")
    REFERENCES "actions"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "events"
    ADD CONSTRAINT "events_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "notification_queue"
    ADD CONSTRAINT "notification_queue_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "notification_queue"
    ADD CONSTRAINT "notification_queue_fk_1"
    FOREIGN KEY("subscriptionId")
    REFERENCES "push_subscriptions"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "notification_topics"
    ADD CONSTRAINT "notification_topics_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "push_subscriptions"
    ADD CONSTRAINT "push_subscriptions_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR rmotly
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('rmotly', '20260116224404522-add-auth-tables', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260116224404522-add-auth-tables', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
