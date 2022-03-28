git checkout main;

clone_transpiler_repo() 
{
	if $(curl https://raw.githubusercontent.com/$1/ERC721A-Transpiler/main/README.md | \
		grep "404: Not Found" >/dev/null 2>&1); then
		echo "$1/ERC721A-Transpiler Github repo not found.";
	else
		git clone "https://github.com/$1/ERC721A-Transpiler.git";
	fi
}

# Download the latest ERC721A-Transpiler.
if [[ -f "ERC721A-Transpiler/package.json" ]]; then
	cd ERC721A-Transpiler;
	git fetch --all; 
	git reset --hard origin/main;
	cd ..;
else
	clone_transpiler_repo "Vectorized";
	clone_transpiler_repo "chiru-labs";
fi

# Transpile.
cd ERC721A-Transpiler;
npm ci;
./scripts/transpile.sh;
cd ..;

# Copy contracts and test folders
rm -r contracts; 
cp -r ERC721A-Transpiler/contracts contracts;
rm -r test; 
cp -r ERC721A-Transpiler/ERC721A/test test;

# Get the last commit hash of ERC721A
cd ERC721A-Transpiler/ERC721A;
commit="$(git rev-parse HEAD)";
cd ../..;

# Commit and push
git config user.name 'github-actions';
git config user.email '41898282+github-actions[bot]@users.noreply.github.com';
git add -A;
(git commit -m "Transpile chiru-labs/ERC721A@$commit" && git push origin main) || echo "No changes to commit";
