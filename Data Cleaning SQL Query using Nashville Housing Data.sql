/*

Cleaning Data in SQL Queries

*/

Select*
From [PortfolioProject ].dbo.NashvilleHousing

---------------------------------------------------------------------------------------

-- Standardise Date Format (Using CONVERT)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [PortfolioProject ].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate=Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted=Convert(Date,SaleDate)


---------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [PortfolioProject ].dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

-- First step is to join the ParcelID's that are the same but has differring UniqueID so that the PropertyAddress related 
-- to the ParcelID is uniform accross the data
-- Second step is to populate the NULL rows with the relative Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- Third step is to update the table
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null
--Fourth Step is to run Step one again. The output should have no null values now.

---------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

--Step one is to view the data that we want to split into different columns
Select PropertyAddress
From [PortfolioProject ].dbo.NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

--Step two we want to split the address and city
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From [PortfolioProject ].dbo.NashvilleHousing

--Step 3 add the split data and create the 2 new columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add PropertySpliCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySpliCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--View results
Select*

From [PortfolioProject ].dbo.NashvilleHousing


-- Breaking out OwnerAddress into Individual Columns (Address, City, State) using  PARSENAME 

--Viewing the data
Select OwnerAddress
From [PortfolioProject ].dbo.NashvilleHousing

--Using PARSENAME to seperate the data
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
, PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
, PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

From [PortfolioProject ].dbo.NashvilleHousing

-- Altering the table, updating the table, adding the new columns

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 



ALTER TABLE NashvilleHousing
Add OwnerSpliCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySpliCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 



ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


--View Changes
Select * 
From [PortfolioProject ].dbo.NashvilleHousing

---------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From [PortfolioProject ].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


/* Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant 
	END
From [PortfolioProject ].dbo.NashvilleHousing */


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant 
	END

---------------------------------------------------------------------------------------

-- Remove Duplicates (CTE and Window Functions)


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [PortfolioProject ].dbo.NashvilleHousing
--Order by ParcelID
)
/* Removes Duplicates
Delete 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
*/

--Check if there are any duplicates 
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------

-- Delete unused columns (Do not do this to raw data)

Select * 
From [PortfolioProject ].dbo.NashvilleHousing


ALTER TABLE [PortfolioProject ].dbo.NashvilleHousing
DROP COLUMN TaxDistrict, PropertyAddress
			
ALTER TABLE [PortfolioProject ].dbo.NashvilleHousing
DROP COLUMN SaleDate

---------------------------------------------------------------------------------------


