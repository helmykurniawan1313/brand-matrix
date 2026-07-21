<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Services\InstagramInsightsService;
use App\Services\InstagramOAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class InstagramController extends Controller
{
    public function redirect(Request $request, Account $account, InstagramOAuthService $oauth): RedirectResponse
    {
        $state = Str::random(40);

        $request->session()->put('ig_oauth_state', $state);
        $request->session()->put('ig_oauth_account_id', $account->id);

        return redirect()->away($oauth->authorizeUrl($state));
    }

    public function callback(Request $request, InstagramOAuthService $oauth): RedirectResponse
    {
        $expectedState = $request->session()->pull('ig_oauth_state');
        $accountId = $request->session()->pull('ig_oauth_account_id');

        if (! $accountId || ! $expectedState || $request->query('state') !== $expectedState) {
            abort(419, 'Invalid or expired Instagram OAuth state.');
        }

        $account = Account::findOrFail($accountId);

        if ($request->query('error')) {
            return redirect('/accounts')->with('ig_error', 'Instagram connection was cancelled or denied.');
        }

        $code = $request->query('code');

        if (! $code) {
            return redirect('/accounts')->with('ig_error', 'Instagram did not return an authorization code.');
        }

        try {
            $result = $oauth->exchangeCodeForLongLivedToken($code);
        } catch (\Throwable $e) {
            return redirect('/accounts')->with('ig_error', 'Instagram token exchange failed: '.$e->getMessage());
        }

        $account->forceFill([
            'ig_business_id' => $result['ig_business_id'],
            'ig_access_token' => $result['access_token'],
            'ig_token_expires_at' => now()->addSeconds($result['expires_in_seconds']),
            'ig_connected_at' => now(),
        ])->save();

        return redirect('/accounts')->with('ig_success', "Instagram connected for {$account->name}.");
    }

    public function connect(Request $request, Account $account): RedirectResponse
    {
        $data = $request->validate([
            'ig_business_id' => ['required', 'string'],
            'ig_access_token' => ['required', 'string'],
        ]);

        $account->forceFill([
            'ig_business_id' => $data['ig_business_id'],
            'ig_access_token' => $data['ig_access_token'],
            'ig_connected_at' => now(),
        ])->save();

        return back();
    }

    public function disconnect(Account $account): RedirectResponse
    {
        $account->forceFill([
            'ig_business_id' => null,
            'ig_username' => null,
            'ig_access_token' => null,
            'ig_token_expires_at' => null,
            'ig_connected_at' => null,
        ])->save();

        return back();
    }

    public function show(Account $account, InstagramInsightsService $insights): JsonResponse
    {
        if (! $account->ig_business_id || ! $account->ig_access_token) {
            return response()->json(['message' => 'This account is not connected to Instagram yet.'], 422);
        }

        try {
            $profile = $insights->profile($account);
            $daily = $insights->dailyInsights($account);
            $media = $insights->media($account);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Instagram API error: '.$e->getMessage()], 422);
        }

        if ($profile['username'] !== $account->ig_username) {
            $account->forceFill(['ig_username' => $profile['username']])->save();
        }

        return response()->json([
            'profile' => $profile,
            'daily_insights' => $daily,
            'media' => $media,
        ]);
    }

    public function mediaInsights(Request $request, Account $account, InstagramInsightsService $insights): JsonResponse
    {
        $data = $request->validate([
            'media_id' => ['required', 'string'],
            'media_product_type' => ['required', 'string'],
        ]);

        if (! $account->ig_business_id || ! $account->ig_access_token) {
            return response()->json(['message' => 'This account is not connected to Instagram yet.'], 422);
        }

        try {
            $result = $insights->mediaInsights($account, $data['media_id'], $data['media_product_type']);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Instagram API error: '.$e->getMessage()], 422);
        }

        return response()->json(['insights' => $result]);
    }
}
