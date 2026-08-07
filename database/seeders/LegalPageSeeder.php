<?php

namespace Database\Seeders;

use App\Models\LegalPage;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class LegalPageSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        LegalPage::updateOrCreate(
            ['slug' => LegalPage::PRIVACY_POLICY],
            [
                'title' => 'Privacy Policy',
                'content_html' => <<<'HTML'
                    <p>{{ app_name }} ("we", "our", "the app") is an internal social media performance dashboard used to track and score brand accounts across reporting periods. This page explains what data we collect through Instagram integration, why, and how it is handled.</p>
                    <h2>What we collect from Instagram</h2>
                    <p>When an account owner connects their Instagram professional account, we access:</p>
                    <ul>
                        <li>Basic profile information (username, follower count, media count)</li>
                        <li>Account-level insight metrics (reach, views, accounts engaged, total interactions)</li>
                        <li>Post and Reel-level insight metrics for content published by the connected account (reach, likes, comments, shares, saved, views, and Reels watch-time metrics)</li>
                    </ul>
                    <p>We only request the minimum permissions needed for this purpose: <code>instagram_business_basic</code> and <code>instagram_business_manage_insights</code>. We do not request or use permissions to publish content, read direct messages, or access data unrelated to performance reporting.</p>
                    <h2>How we use this data</h2>
                    <p>Instagram data is used exclusively to populate internal performance dashboards — growth, visibility, and engagement scoring for the connected account, and per-post analytics shown to the team members managing that account. It is not sold, shared with third parties, or used for advertising.</p>
                    <h2>How we store this data</h2>
                    <p>Access tokens are encrypted at rest and are never exposed in any API response or user interface. Insight metrics are stored in our database to support historical reporting and are only accessible to authenticated users of this application.</p>
                    <h2>Data retention and deletion</h2>
                    <p>Data collected for a connected account is retained for as long as the account remains connected. An account owner can disconnect Instagram at any time from within the app, which immediately removes the stored access token. To request full deletion of all associated data, see our Data Deletion Instructions.</p>
                    <h2>Contact</h2>
                    <p>For questions about this policy or to request data deletion, contact the app administrator.</p>
                    HTML,
            ]
        );

        LegalPage::updateOrCreate(
            ['slug' => LegalPage::DATA_DELETION],
            [
                'title' => 'Data Deletion Instructions',
                'content_html' => <<<'HTML'
                    <p>If you have connected an Instagram professional account to {{ app_name }} and would like your data removed, you can do so in either of the following ways.</p>
                    <h2>Option 1 — Disconnect from within the app</h2>
                    <ol>
                        <li>Sign in to {{ app_name }}.</li>
                        <li>Go to the Accounts page and locate the connected Instagram account.</li>
                        <li>Select "Disconnect Instagram."</li>
                    </ol>
                    <p>This immediately deletes the stored Instagram access token and business account ID. The account will no longer be able to fetch new data from Instagram.</p>
                    <h2>Option 2 — Request full deletion</h2>
                    <p>To request permanent deletion of all historical Instagram-derived data associated with an account (daily snapshots, post insights, and any cached profile information), email the app administrator with the account name and the Instagram username that was connected. Requests are processed within 30 days.</p>
                    <h2>What gets deleted</h2>
                    <ul>
                        <li>The encrypted Instagram access token and business account ID</li>
                        <li>Stored daily insight snapshots for the account</li>
                        <li>Stored post/Reel insight snapshots linked to that account's performance records</li>
                    </ul>
                    <p>Manually entered performance records (post dates, crew assignments, uploaded proof images) are not tied to the Instagram connection and are retained separately unless deletion of the entire account is also requested.</p>
                    HTML,
            ]
        );
    }
}
