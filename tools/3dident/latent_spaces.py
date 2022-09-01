"""Classes that combine spaces with specific probability densities."""

from typing import Callable, List
from spaces import Space
import torch
import numpy as np


class LatentSpace:
    """Combines a topological space with a marginal and conditional density to sample from."""

    def __init__(
        self, space: Space, sample_marginal: Callable, sample_conditional: Callable
    ):
        self.space = space
        self._sample_marginal = sample_marginal
        self._sample_conditional = sample_conditional

    @property
    def sample_conditional(self):
        if self._sample_conditional is None:
            raise RuntimeError("sample_conditional was not set")
        return lambda *args, **kwargs: self._sample_conditional(
            self.space, *args, **kwargs
        )

    @sample_conditional.setter
    def sample_conditional(self, value: Callable):
        assert callable(value)
        self._sample_conditional = value

    @property
    def sample_marginal(self):
        if self._sample_marginal is None:
            raise RuntimeError("sample_marginal was not set")
        return lambda *args, **kwargs: self._sample_marginal(
            self.space, *args, **kwargs
        )

    @sample_marginal.setter
    def sample_marginal(self, value: Callable):
        assert callable(value)
        self._sample_marginal = value

    @property
    def dim(self):
        return self.space.dim


class ProductLatentSpace(LatentSpace):
    """A latent space which is the cartesian product of other latent spaces."""

    def __init__(self, spaces: List[LatentSpace]):
        self.spaces = spaces

    def sample_conditional(self, z, std, size, **kwargs):
        x = []
        n = 0
        for i, s in enumerate(self.spaces):
            if len(z.shape) == 1:
                z_s = z[n : n + s.space.n]
            else:
                z_s = z[:, n : n + s.space.n]
            n += s.space.n
            x.append(s.sample_conditional(mean=z_s, std=std[i], size=size, **kwargs))

        return torch.cat(x, -1)

    def sample_marginal(self, size, **kwargs):
        x = [s.sample_marginal(size=size, **kwargs) for s in self.spaces]

        return torch.cat(x, -1)

    def sample_marginal_causal(self, std, size, ms, **kwargs):
        x = [s.sample_marginal(torch.tensor([0.0]),0.0, size=size, **kwargs) for i, s in enumerate(self.spaces)]
        final_x = []
        for i, s in enumerate(self.spaces):
            if i==2 and std[i] is not None:
                if ms == "hues":final_x.append(s.sample_marginal(x[6],std[i],size=size,**kwargs))
                elif ms == "rotations":final_x.append(s.sample_marginal(x[9],std[i],size=size,**kwargs))
                print(x[9],std[i])
            elif i==6 and std[i] is not None:
                if ms == "hues":final_x.append(s.sample_marginal(x[2],std[i],size=size,**kwargs))
                elif ms == "positions":final_x.append(s.sample_marginal(x[9],std[i],size=size,**kwargs))
            elif i==9 and std[i] is not None:
                if ms == "positions":final_x.append(s.sample_marginal(x[6],std[i],size=size,**kwargs))
                elif ms == "rotations":final_x.append(s.sample_marginal(x[2],std[i],size=size,**kwargs))
            else: final_x.append(x[i])

        final_final_x = []
        for i, s in enumerate(self.spaces):
            if i==0 and std[i] is not None:final_final_x.append(s.sample_marginal(final_x[1],std[i],size=size,**kwargs))
            elif i==5 and std[i] is not None:final_final_x.append(s.sample_marginal(final_x[3],std[i],size=size,**kwargs))
            elif i==7 and std[i] is not None:final_final_x.append(s.sample_marginal(final_x[8],std[i],size=size,**kwargs))
            else: final_final_x.append(final_x[i])

        return torch.cat(final_final_x, -1)

    @property
    def dim(self):
        return sum([s.dim for s in self.spaces])
