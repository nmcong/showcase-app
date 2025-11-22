interface MarketplaceLinksProps {
  unrealMarketUrl?: string;
  unityMarketUrl?: string;
  price?: number;
}

export function MarketplaceLinks({
  unrealMarketUrl,
  unityMarketUrl,
  price,
}: MarketplaceLinksProps) {
  const hasLinks = unrealMarketUrl || unityMarketUrl;

  if (!hasLinks) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold text-gray-800 mb-4">Purchase</h2>
      
      {price && (
        <div className="mb-4">
          <span className="text-3xl font-bold text-green-600">${price.toFixed(2)}</span>
        </div>
      )}

      <div className="space-y-3">
        {unrealMarketUrl && (
          <a
            href={unrealMarketUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-center gap-2 w-full px-6 py-3 bg-gradient-to-r from-gray-800 to-gray-900 text-white rounded-md hover:from-gray-700 hover:to-gray-800 transition-all"
          >
            <span className="text-xl">🎮</span>
            <span className="font-semibold">View on Unreal Marketplace</span>
          </a>
        )}

        {unityMarketUrl && (
          <a
            href={unityMarketUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-center gap-2 w-full px-6 py-3 bg-gradient-to-r from-gray-700 to-gray-800 text-white rounded-md hover:from-gray-600 hover:to-gray-700 transition-all"
          >
            <span className="text-xl">🎯</span>
            <span className="font-semibold">View on Unity Asset Store</span>
          </a>
        )}
      </div>

      <p className="text-sm text-gray-500 mt-4 text-center">
        Click to be redirected to the marketplace
      </p>
    </div>
  );
}

