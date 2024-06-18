/*
Cleaning Data
*/

Select *
From portfolioProject.dbo.Housing

--Standardize Date Format

Select saledateConverted, CONVERT(date,Saledate)
from portfolioProject.dbo.Housing

Alter table portfolioProject.dbo.Housing
add saledateconverted date;

Update portfolioProject.dbo.Housing
Set saledateconverted = CONVERT(Date,Saledate)

-- Populate property Address data

Select *
from portfolioProject.dbo.Housing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.Housing a
Join portfolioProject.dbo.Housing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.Housing a
Join portfolioProject.dbo.Housing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaing out Address into individual Columns (Adress, City)

Select PropertyAddress
from portfolioProject.dbo.Housing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as address

from portfolioProject.dbo.Housing

Alter table portfolioProject.dbo.Housing
add propertysplitaddress Nvarchar(255);

Update portfolioProject.dbo.Housing
Set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

Alter table portfolioProject.dbo.Housing
add propertysplitcity Nvarchar(255);

Update portfolioProject.dbo.Housing
Set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

Select *

from portfolioProject.dbo.Housing

--Change Y and N to Yes and No in "sold as Vacant" field 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolioProject.dbo.Housing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from portfolioProject.dbo.Housing

Update portfolioProject.dbo.Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-- Remove Duplicates

With RowNumCTE As(
select *,
ROW_NUMBER() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order By
UniqueID
) row_num


from portfolioProject.dbo.Housing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
--Order by PropertyAddress

Select *
from portfolioProject.dbo.Housing
 